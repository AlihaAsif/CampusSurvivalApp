enum LostKind { lost, found }

enum ItemCategory { electronics, bag, card, keys, bottle, book, other }

extension ItemCategoryX on ItemCategory {
  String get label => switch (this) {
    ItemCategory.electronics => 'Electronics',
    ItemCategory.bag => 'Bag',
    ItemCategory.card => 'Card / ID',
    ItemCategory.keys => 'Keys',
    ItemCategory.bottle => 'Bottle',
    ItemCategory.book => 'Book / Notes',
    ItemCategory.other => 'Other',
  };

  int get colorValue => switch (this) {
    ItemCategory.electronics => 0xFF3D5AA9,
    ItemCategory.bag => 0xFF8A5300,
    ItemCategory.card => 0xFF256B48,
    ItemCategory.keys => 0xFF725572,
    ItemCategory.bottle => 0xFF1F6683,
    ItemCategory.book => 0xFFBA1A1A,
    ItemCategory.other => 0xFF585E71,
  };
}

class LostItem {
  final String id;
  final LostKind kind;
  final ItemCategory category;
  final String title;
  final String location;
  final DateTime postedAt;
  final String postedByName;
  final String postedByUid;
  final String? imageUrl;
  final String? contactNote;
  final bool resolved;

  const LostItem({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.location,
    required this.postedAt,
    required this.postedByName,
    required this.postedByUid,
    this.imageUrl,
    this.contactNote,
    this.resolved = false,
  });

  /// Resolved items stay visible for a week, then drop off the list.
  bool get shouldShow {
    if (!resolved) return true;
    return DateTime.now().difference(postedAt).inDays < 7;
  }

  String get relativeTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final posted = DateTime(postedAt.year, postedAt.month, postedAt.day);
    final days = today.difference(posted).inDays;

    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${postedAt.day} ${months[postedAt.month - 1]}';
  }
}