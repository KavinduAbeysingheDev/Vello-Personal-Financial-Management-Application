class EventFormValidator {
  static String? validateTitle(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Title is required';
    if (trimmed.length < 2) return 'Title is too short';
    return null;
  }

  static String? validateBudget(double? value) {
    if (value == null) return 'Budget is required';
    if (value <= 0) return 'Budget must be greater than 0';
    return null;
  }

  static String? validateSpent(double? value) {
    if (value == null) return 'Spent amount is required';
    if (value < 0) return 'Spent amount cannot be negative';
    return null;
  }

  static double? parseAmount(String raw) {
    final cleaned = raw.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}

