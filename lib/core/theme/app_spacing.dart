/// Spacing scale: 4, 8, 12, 16, 20, 24. Nothing outside this list.
class AppSpacing {
  AppSpacing._(); // never create an instance of this class

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Left/right padding of every screen body.
  static const double screenH = 16;

  /// Padding inside a card.
  static const double cardPad = 14;

  /// Vertical gap between two stacked cards.
  static const double cardGap = 10;

  /// Space above a section header.
  static const double section = 18;
}

/// Corner radii used across the app.
class AppRadius {
  AppRadius._();

  static const double card = 12;
  static const double chip = 8;
  static const double fab = 16;
  static const double icon = 20; // 40x40 circle => radius 20
}