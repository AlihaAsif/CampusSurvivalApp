
class AttendanceMath {
  AttendanceMath._();

  static const double threshold = 0.75;

  static double percent(int attended, int held) {
    if (held == 0) return 0;
    return attended / held;
  }

  static int safeSkips(int attended, int held) {
    if (held == 0) return 0;
    final result = (attended / threshold).floor() - held;
    return result > 0 ? result : 0;
  }

  static int recoveryNeeded(int attended, int held) {
    if (held == 0) return 0;
    if (attended / held >= threshold) return 0;
    return ((threshold * held - attended) / (1 - threshold)).ceil();
  }
}