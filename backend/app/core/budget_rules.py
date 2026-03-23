# Budget rule constants — easy to tune without touching service logic

# Savings
MIN_SAVINGS_PERCENTAGE = 0.10        # At least 10% of income
IDEAL_SAVINGS_PERCENTAGE = 0.20      # Ideal is 20%

# Essentials (rent, bills, groceries, transport)
ESSENTIAL_SPENDING_CAP = 0.50        # 50% of income max on essentials

# Discretionary (entertainment, dining, shopping)
DISCRETIONARY_SPENDING_CAP = 0.30    # 30% of income at most

# Emergency
EMERGENCY_BUFFER_PERCENTAGE = 0.05   # 5% of income as emergency buffer

# Warning thresholds
OVERSPENDING_THRESHOLD = 1.0         # expense / income ratio ≥ 1.0
TIGHT_BUDGET_THRESHOLD = 0.85        # ratio ≥ 85%
MANAGEABLE_THRESHOLD = 0.70          # ratio ≥ 70%

# Default category allocations (% of disposable income after fixed expenses)
DEFAULT_CATEGORY_WEIGHTS = {
    "food":          0.30,
    "transport":     0.15,
    "bills":         0.10,
    "entertainment": 0.10,
    "emergency":     0.05,
    "personal":      0.10,
    "savings":       0.20,
}
