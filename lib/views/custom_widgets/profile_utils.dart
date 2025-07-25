class ProfileUtils {
  /// Formats a date string into a readable month-year format
  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Calculates responsive avatar radius based on screen size
  static double getAvatarRadius(bool isTablet) {
    return isTablet ? 80.0 : 65.0;
  }

  /// Calculates responsive horizontal padding
  static double getHorizontalPadding(bool isLargeScreen, double screenWidth) {
    return isLargeScreen ? screenWidth * 0.15 : 16.0;
  }

  /// Gets maximum content width for responsive design
  static double getMaxContentWidth(bool isLargeScreen) {
    return isLargeScreen ? 700.0 : double.infinity;
  }

  /// Determines if the screen is a tablet
  static bool isTabletScreen(double screenWidth) {
    return screenWidth > 600;
  }

  /// Determines if the screen is a large screen
  static bool isLargeScreen(double screenWidth) {
    return screenWidth > 900;
  }
}
