/// Enum representing all expense/income categories in Vello.
enum Category {
  food('Food', '🍔'),
  transport('Transport', '🚗'),
  entertainment('Entertainment', '🎬'),
  shopping('Shopping', '🛍️'),
  bills('Bills', '📄'),
  health('Health', '🏥'),
  education('Education', '📚'),
  salary('Salary', '💰'),
  freelance('Freelance', '💼'),
  investment('Investment', '📈'),
  gift('Gift', '🎁'),
  subscription('Subscription', '🔄'),
  groceries('Groceries', '🛒'),
  rent('Rent', '🏠'),
  utilities('Utilities', '⚡'),
  other('Other', '📦');

  const Category(this.displayName, this.emoji);

  final String displayName;
  final String emoji;

  /// Match a category from a raw string (case-insensitive).
  static Category fromString(String value) {
    final lower = value.toLowerCase().trim();
    for (final cat in Category.values) {
      if (cat.name.toLowerCase() == lower ||
          cat.displayName.toLowerCase() == lower) {
        return cat;
      }
    }
    return Category.other;
  }
}
