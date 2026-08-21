enum PlaceCategory {
  academic,
  library,
  lab,
  cafeteria,
  admin,
  medical,
  mosque,
  sports,
  parking,
  hostel,
  transport,
  other,
}

extension PlaceCategoryX on PlaceCategory {
  String get label => switch (this) {
    PlaceCategory.academic => 'Academic block',
    PlaceCategory.library => 'Library',
    PlaceCategory.lab => 'Lab',
    PlaceCategory.cafeteria => 'Cafeteria',
    PlaceCategory.admin => 'Admin',
    PlaceCategory.medical => 'Medical',
    PlaceCategory.mosque => 'Mosque',
    PlaceCategory.sports => 'Sports',
    PlaceCategory.parking => 'Parking',
    PlaceCategory.hostel => 'Hostel',
    PlaceCategory.transport => 'Transport',
    PlaceCategory.other => 'Other',
  };

  int get colorValue => switch (this) {
    PlaceCategory.academic => 0xFF3D5AA9,
    PlaceCategory.library => 0xFF725572,
    PlaceCategory.lab => 0xFF1F6683,
    PlaceCategory.cafeteria => 0xFF8A5300,
    PlaceCategory.admin => 0xFF585E71,
    PlaceCategory.medical => 0xFFBA1A1A,
    PlaceCategory.mosque => 0xFF256B48,
    PlaceCategory.sports => 0xFF8A5300,
    PlaceCategory.parking => 0xFF585E71,
    PlaceCategory.hostel => 0xFF725572,
    PlaceCategory.transport => 0xFF1F6683,
    PlaceCategory.other => 0xFF585E71,
  };
}

class CampusPlace {
  final String id;
  final String name;
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final String? description;

  const CampusPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.description,
  });

  bool matches(String query) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return true;
    return name.toLowerCase().contains(text) ||
        category.label.toLowerCase().contains(text) ||
        (description ?? '').toLowerCase().contains(text);
  }
}