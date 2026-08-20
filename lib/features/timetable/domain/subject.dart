
const List<int> subjectColors = [
  0xFF3D5AA9,
  0xFF256B48,
  0xFF8A5300,
  0xFF725572,
  0xFF1F6683,
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