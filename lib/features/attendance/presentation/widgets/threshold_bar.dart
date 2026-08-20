import 'package:flutter/material.dart';

/// A progress bar with a tick mark showing the 75% requirement.
class ThresholdBar extends StatelessWidget {
  const ThresholdBar({
    super.key,
    required this.value,
    required this.color,
    this.threshold,
  });

  final double value;
  final Color color;
  final double? threshold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 6,
                color: color,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          if (threshold != null)
            LayoutBuilder(
              builder: (context, constraints) {
                return Positioned(
                  left: constraints.maxWidth * threshold!,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    height: 10,
                    color: scheme.onSurfaceVariant,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}