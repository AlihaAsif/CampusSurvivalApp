class UserProfile {
  final String uid;
  final String name;
  final String rollNumber;
  final int semester;
  final String section;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.rollNumber,
    required this.semester,
    required this.section,
  });

  bool get isComplete => rollNumber.isNotEmpty && semester > 0;

  static final RegExp rollNumberPattern =
  RegExp(r'^(FA|SP|SU)\d{2}-[A-Z]{2,4}-\d{3}$');

  static bool isValidRollNumber(String value) {
    return rollNumberPattern.hasMatch(value.trim().toUpperCase());
  }

  UserProfile copyWith({
    String? name,
    String? rollNumber,
    int? semester,
    String? section,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      semester: semester ?? this.semester,
      section: section ?? this.section,
    );
  }
}