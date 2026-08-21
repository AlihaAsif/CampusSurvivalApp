import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ocr_service.dart';
import '../domain/parsed_slot.dart';
import '../domain/timetable_parser.dart';

enum ImportStage {
  idle,
  reading,
  finding,
  matching,
  building,
  pickSection,
  review,
  error,
}

class ImportState {
  const ImportState({
    this.stage = ImportStage.idle,
    this.fileName,
    this.allSlots = const [],
    this.sections = const [],
    this.chosenSection,
    this.errorMessage,
  });

  final ImportStage stage;
  final String? fileName;

  /// Everything found in the sheet, all sections.
  final List<ParsedSlot> allSlots;

  /// Section labels the sheet contains.
  final List<String> sections;

  final String? chosenSection;
  final String? errorMessage;

  /// Only the rows for the chosen section.
  List<ParsedSlot> get slots {
    if (chosenSection == null) return allSlots;
    return allSlots
        .where((slot) => slot.section == chosenSection)
        .toList();
  }

  ImportState copyWith({
    ImportStage? stage,
    String? fileName,
    List<ParsedSlot>? allSlots,
    List<String>? sections,
    String? chosenSection,
    String? errorMessage,
  }) {
    return ImportState(
      stage: stage ?? this.stage,
      fileName: fileName ?? this.fileName,
      allSlots: allSlots ?? this.allSlots,
      sections: sections ?? this.sections,
      chosenSection: chosenSection ?? this.chosenSection,
      errorMessage: errorMessage,
    );
  }
}

class ImportController extends Notifier<ImportState> {
  @override
  ImportState build() => const ImportState();

  void reset() => state = const ImportState();

  Future<void> importFile(File file, String fileName) async {
    state = ImportState(stage: ImportStage.reading, fileName: fileName);

    try {
      final text = await OcrService.read(file);
      await _pause();

      if (text.trim().isEmpty) {
        _fail("Couldn't read that file. Try a clearer photo, or add "
            'classes manually.');
        return;
      }

      state = state.copyWith(stage: ImportStage.finding);
      await _pause();

      state = state.copyWith(stage: ImportStage.matching);
      final slots = TimetableParser.parse(text);
      final sections = TimetableParser.findSections(text);
      await _pause();

      if (slots.isEmpty) {
        _fail('No classes found in that file. Try a clearer photo, or '
            'add classes manually.');
        return;
      }

      state = state.copyWith(stage: ImportStage.building);
      await _pause();

      // More than one section in the sheet — the student must choose.
      if (sections.length > 1) {
        state = state.copyWith(
          stage: ImportStage.pickSection,
          allSlots: slots,
          sections: sections,
        );
        return;
      }

      state = state.copyWith(
        stage: ImportStage.review,
        allSlots: slots,
        sections: sections,
        chosenSection: sections.isEmpty ? null : sections.first,
      );
    } catch (e) {
      _fail('Something went wrong reading that file.');
    }
  }

  void chooseSection(String? section) {
    state = state.copyWith(
      stage: ImportStage.review,
      chosenSection: section,
    );
  }

  void backToSectionPicker() {
    state = state.copyWith(stage: ImportStage.pickSection);
  }

  void removeSlot(ParsedSlot slot) {
    final list = [...state.allSlots]..remove(slot);
    state = state.copyWith(allSlots: list);
  }

  void updateSlot(ParsedSlot oldSlot, ParsedSlot newSlot) {
    final list =
        state.allSlots.map((s) => s == oldSlot ? newSlot : s).toList();
    state = state.copyWith(allSlots: list);
  }

  void _fail(String message) {
    state = state.copyWith(
      stage: ImportStage.error,
      errorMessage: message,
    );
  }

  Future<void> _pause() =>
      Future.delayed(const Duration(milliseconds: 400));
}

final importControllerProvider =
NotifierProvider<ImportController, ImportState>(ImportController.new);