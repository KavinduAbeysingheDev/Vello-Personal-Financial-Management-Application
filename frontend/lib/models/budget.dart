class Budget {
  final String id;
  final String? userId;
  final String category;
  final double amountLimit;
  final double currentSpent;
  final String period;

  Budget({
    required this.id,
    this.userId,
    required this.category,
    required this.amountLimit,
    this.currentSpent = 0.0,
    this.period = 'monthly',
  });

  bool get isOverspent => currentSpent > amountLimit;
  double get usagePercent => amountLimit > 0 ? (currentSpent / amountLimit) : 0.0;

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'amount_limit': amountLimit,
      'current_spent': currentSpent,
      'period': period,
    };
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'category': category,
      'amount_limit': amountLimit,
      'current_spent': currentSpent,
    };
  }

  factory Budget.fromSupabase(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      userId: map['user_id'],
      category: map['category'],
      amountLimit: (map['amount_limit'] as num).toDouble(),
      currentSpent: (map['current_spent'] as num).toDouble(),
      period: map['period'],
    );
  }

  Budget copyWith({
    String? id,
    String? userId,
    String? category,
    double? amountLimit,
    double? currentSpent,
    String? period,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amountLimit: amountLimit ?? this.amountLimit,
      currentSpent: currentSpent ?? this.currentSpent,
      period: period ?? this.period,
    );
  }
}
