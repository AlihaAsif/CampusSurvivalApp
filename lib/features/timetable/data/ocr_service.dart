import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

/// Reads text out of an image or PDF, on the device.
class OcrService {
  OcrService._();

  static Future<String> readImage(File file) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;
      debugPrint('OcrService.readImage file: ${file.path}, exists: $exists, bytes: $size');

      if (!exists || size == 0) {
        debugPrint('OcrService.readImage file empty or missing!');
        return '';
      }

      final input = InputImage.fromFile(file);
      final result = await recognizer.processImage(input);
      final text = _reconstructSpatialRows(result);
      debugPrint('OcrService.readImage extracted length: ${text.length}');
      if (text.isNotEmpty) {
        final snippet = text.length > 150
            ? text.substring(0, 150).replaceAll('\n', ' ')
            : text.replaceAll('\n', ' ');
        debugPrint('OcrService.readImage snippet: "$snippet"');
      }
      return text;
    } catch (e, stack) {
      debugPrint('OcrService.readImage error: $e\n$stack');
      return '';
    } finally {
      await recognizer.close();
    }
  }

  /// Groups ML Kit recognized text lines horizontally into rows based on bounding box Y/X coordinates.
  static String _reconstructSpatialRows(RecognizedText recognizedText) {
    final allLines = <_LineInfo>[];

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        if (line.text.trim().isNotEmpty) {
          allLines.add(_LineInfo(line.text, line.boundingBox));
        }
      }
    }

    if (allLines.isEmpty) return recognizedText.text;

    // Sort lines top-to-bottom
    allLines.sort((a, b) => a.box.top.compareTo(b.box.top));

    final rows = <List<_LineInfo>>[];

    for (final line in allLines) {
      bool added = false;
      for (final row in rows) {
        final rowY = row.map((l) => l.box.center.dy).reduce((a, b) => a + b) / row.length;
        final avgHeight = row.map((l) => l.box.height).reduce((a, b) => a + b) / row.length;

        final threshold = (avgHeight * 0.65).clamp(10.0, 35.0);
        if ((line.box.center.dy - rowY).abs() <= threshold) {
          row.add(line);
          added = true;
          break;
        }
      }

      if (!added) {
        rows.add([line]);
      }
    }

    // Sort rows top-to-bottom by row average Y
    rows.sort((r1, r2) {
      final y1 = r1.map((l) => l.box.top).reduce((a, b) => a + b) / r1.length;
      final y2 = r2.map((l) => l.box.top).reduce((a, b) => a + b) / r2.length;
      return y1.compareTo(y2);
    });

    final buffer = StringBuffer();
    for (final row in rows) {
      // Sort left-to-right within the same row
      row.sort((a, b) => a.box.left.compareTo(b.box.left));
      final rowText = row.map((l) => l.text).join(' ');
      buffer.writeln(rowText);
    }

    final reconstructed = buffer.toString().trim();
    return reconstructed.isNotEmpty ? reconstructed : recognizedText.text;
  }

  /// Extracts text directly from digital PDFs using Syncfusion PDF extractor.
  /// Falls back to page rendering + ML Kit OCR if text extraction yields no text.
  static Future<String> readPdf(File file) async {
    try {
      final exists = await file.exists();
      if (!exists) {
        debugPrint('OcrService.readPdf file missing!');
        return '';
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint('OcrService.readPdf file empty!');
        return '';
      }

      sf.PdfDocument? document;
      try {
        document = sf.PdfDocument(inputBytes: bytes);
        final String extractedText = sf.PdfTextExtractor(document).extractText();

        debugPrint('OcrService.readPdf direct extraction length: ${extractedText.length}');

        if (extractedText.trim().isNotEmpty) {
          final snippet = extractedText.length > 150
              ? extractedText.substring(0, 150).replaceAll('\n', ' ')
              : extractedText.replaceAll('\n', ' ');
          debugPrint('OcrService.readPdf direct text snippet: "$snippet"');
          return extractedText;
        }

        debugPrint('OcrService.readPdf direct extraction empty; falling back to OCR rendering');
      } finally {
        document?.dispose();
      }
    } catch (e, stack) {
      debugPrint('OcrService.readPdf direct extraction error: $e\n$stack');
    }

    return _readPdfViaOcr(file);
  }

  /// Fallback: PDFs rendered to images first, then ML Kit OCR is executed on rendered images.
  static Future<String> _readPdfViaOcr(File file) async {
    final buffer = StringBuffer();

    try {
      final document = await PdfDocument.openFile(file.path);
      final directory = await getTemporaryDirectory();

      try {
        // Timetables are one or two pages. Stop at three.
        final pageCount = document.pagesCount > 3 ? 3 : document.pagesCount;
        debugPrint('OcrService._readPdfViaOcr pageCount: $pageCount');

        for (var i = 1; i <= pageCount; i++) {
          final page = await document.getPage(i);
          debugPrint('OcrService._readPdfViaOcr page $i size: ${page.width}x${page.height}');

          // Render page to image with good resolution (capped at max 2048px)
          double targetWidth = (page.width * 2).toDouble();
          double targetHeight = (page.height * 2).toDouble();
          if (targetWidth > 2048) {
            final scale = 2048 / targetWidth;
            targetWidth = 2048;
            targetHeight = (targetHeight * scale);
          }

          final image = await page.render(
            width: targetWidth,
            height: targetHeight,
            format: PdfPageImageFormat.jpeg,
            backgroundColor: '#FFFFFF',
          );
          await page.close();

          if (image == null) {
            debugPrint('OcrService._readPdfViaOcr page $i rendered null image');
            continue;
          }

          debugPrint('OcrService._readPdfViaOcr page $i rendered image: ${image.width}x${image.height}, bytes: ${image.bytes.length}');

          final temp = File(
            '${directory.path}/page_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await temp.writeAsBytes(image.bytes);

          final pageText = await readImage(temp);
          buffer.writeln(pageText);

          try {
            await temp.delete();
          } catch (_) {}
        }
      } finally {
        await document.close();
      }
    } catch (e, stack) {
      debugPrint('OcrService._readPdfViaOcr error: $e\n$stack');
    }

    return buffer.toString();
  }

  static Future<String> read(File file) async {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    debugPrint('OcrService.read file: ${file.path}, isPdf: $isPdf');
    return isPdf ? await readPdf(file) : await readImage(file);
  }
}

class _LineInfo {
  final String text;
  final Rect box;

  _LineInfo(this.text, this.box);
}