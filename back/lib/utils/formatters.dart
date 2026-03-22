/// Formatting utilities for currency, dates, and percentages.
class Formatters {
  Formatters._();

  /// Format a number as currency string (e.g., "$1,234.56").
  static String currency(double amount, {String symbol = '\$'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add comma separators
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return '${isNegative ? "-" : ""}\$${buffer.toString()}.$decPart';
  }

  /// Format a percentage (e.g., "45.2%").
  static String percent(double value, {int decimals = 1}) {
    return '
${value.toStringAsFixed(decimals)}%';
  }

  /// Format a date as readable string (e.g., "Mar 15, 2026").
  /// Returns 'Invalid date' if the date is invalid.
  static String date(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    
    // ✅ FIXED: Added validation for month range
    if (dt.month < 1 || dt.month > 12) {
      return 'Invalid date';
    }
    
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  /// Format a date range (e.g., "Mar 8 - Mar 15, 2026").
  static String dateRange(DateTime start, DateTime end) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    
    // ✅ FIXED: Added validation for month ranges
    if (start.month < 1 || start.month > 12 || end.month < 1 || end.month > 12) {
      return 'Invalid date range';
    }
    
    if (start.year == end.year && start.month == end.month) {
      return '${months[start.month - 1]} ${start.day} - ${end.day}, ${end.year}';
    }
    return '${date(start)} - ${date(end)}';
  }

  /// Get the start of current week (Monday).
  /// ✅ FIXED: Uses Duration for safe date arithmetic
  static DateTime startOfWeek(DateTime dt) {
    final daysFromMonday = dt.weekday - 1;
    return dt.subtract(Duration(days: daysFromMonday));
  }

  /// Get the start of current month.
  static DateTime startOfMonth(DateTime dt) {
    return DateTime(dt.year, dt.month, 1);
  }

  /// Get the end of current month.
  static DateTime endOfMonth(DateTime dt) {
    return DateTime(dt.year, dt.month + 1, 0, 23, 59, 59);
  }

  /// Format a relative time string (e.g., "2 days ago").
  /// ✅ FIXED: Added validation for negative time differences (future dates)
  static String relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    // Handle future dates
    if (diff.isNegative) {
      final absDiff = dt.difference(now);
      if (absDiff.inDays == 0) return 'today';
      if (absDiff.inDays == 1) return 'tomorrow';
      if (absDiff.inDays < 7) return 'in ${absDiff.inDays} days';
      if (absDiff.inDays < 30) return 'in ${(absDiff.inDays / 7).floor()} weeks';
      if (absDiff.inDays < 365) return 'in ${(absDiff.inDays / 30).floor()} months';
      return 'in ${(absDiff.inDays / 365).floor()} years';
    }

    // Handle past dates (original logic)
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }
}