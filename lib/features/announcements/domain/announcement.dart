class Announcement {
  final String id;
  final String source;
  final String title;
  final String body;
  final DateTime postedAt;
  final bool pinned;

  const Announcement({
    required this.id,
    required this.source,
    required this.title,
    required this.body,
    required this.postedAt,
    this.pinned = false,
  });


  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(postedAt);

    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      if (minutes < 1) return 'Just now';
      return '$minutes min ago';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }

    final today = DateTime(now.year, now.month, now.day);
    final posted = DateTime(postedAt.year, postedAt.month, postedAt.day);
    final days = today.difference(posted).inDays;

    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${postedAt.day} ${months[postedAt.month - 1]}';
  }


  List<String> get paragraphs =>
      body.split('\n\n').where((part) => part.trim().isNotEmpty).toList();
}