
const List<int> subjectColors = [
  0xFFF2691E, // Brand Orange
  0xFF1E2E5C, // Brand Navy Blue
  0xFF3D5AA9, // Brand Accent Blue
  0xFFE55A10, // Bright Orange
  0xFF2B3E75, // Deep Blue
];

class Subject {
  final String id;
  final String code;
  final String name;
  final int colorValue;
  final int classesHeld;
  final int classesAttended;

  const Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.colorValue,
    this.classesHeld = 0,
    this.classesAttended = 0,
  });

  
  static int nextColor(int existingCount) {
    return subjectColors[existingCount % subjectColors.length];
  }
}