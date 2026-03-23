from app.schemas.weekly_budget import (
    WeeklyBudgetInput, WeeklyBudgetResult, BudgetAllocation
)
from app.core.budget_rules import (
    MIN_SAVINGS_PERCENTAGE, IDEAL_SAVINGS_PERCENTAGE,
    ESSENTIAL_SPENDING_CAP, DISCRETIONARY_SPENDING_CAP,
    EMERGENCY_BUFFER_PERCENTAGE, OVERSPENDING_THRESHOLD,
    TIGHT_BUDGET_THRESHOLD, MANAGEABLE_THRESHOLD,
    DEFAULT_CATEGORY_WEIGHTS,
)

class RuleBasedBudgetService:

    @staticmethod
    def generate_plan(data: WeeklyBudgetInput) -> WeeklyBudgetResult:
        warnings: list[str] = []
        suggestions: list[str] = []
        allocations: list[BudgetAllocation] = []

        income = data.weekly_income
        total_fixed = sum(e.amount for e in data.fixed_expenses)
        total_variable = sum(e.amount for e in data.variable_expenses)
        total_expenses = total_fixed + total_variable
        disposable = income - total_fixed  # money after fixed bills

        # ── Expense ratio & status ────────────────────────────────────────
        expense_ratio = total_expenses / income if income > 0 else 999
        if expense_ratio >= OVERSPENDING_THRESHOLD:
            status = "overspending"
            warnings.append("Your total expenses meet or exceed your income.")
        elif expense_ratio >= TIGHT_BUDGET_THRESHOLD:
            status = "tight"
            warnings.append("Your budget is very tight. Consider reducing variable spending.")
        elif expense_ratio >= MANAGEABLE_THRESHOLD:
            status = "manageable"
            suggestions.append("You're doing okay but there's room to optimise savings.")
        else:
            status = "healthy"
            suggestions.append("Great job! Your spending is well within your income.")

        # ── Savings calculation ───────────────────────────────────────────
        ideal_savings = income * IDEAL_SAVINGS_PERCENTAGE
        min_savings = income * MIN_SAVINGS_PERCENTAGE
        actual_surplus = income - total_expenses

        if data.savings_goal > 0:
            recommended_savings = data.savings_goal
            if data.savings_goal > actual_surplus:
                warnings.append(
                    f"Your savings goal (${data.savings_goal:.2f}) "
                    f"exceeds available surplus (${actual_surplus:.2f})."
                )
        else:
            recommended_savings = max(min(ideal_savings, actual_surplus), 0)

        if actual_surplus > 0 and recommended_savings < min_savings:
            suggestions.append(
                f"Try to save at least ${min_savings:.2f}/week (10% of income)."
            )

        # ── Essential vs flexible budgets ──────────────────────────────────
        recommended_essentials = min(total_fixed + (disposable * 0.3), income * ESSENTIAL_SPENDING_CAP)
        remaining_after_savings = max(disposable - recommended_savings, 0)
        recommended_flexible = remaining_after_savings * (1 - EMERGENCY_BUFFER_PERCENTAGE)

        # ── Category allocations ──────────────────────────────────────────
        pool = max(remaining_after_savings, 0)
        for cat_name, weight in DEFAULT_CATEGORY_WEIGHTS.items():
            if cat_name == "savings":
                continue  # savings handled separately
            amt = round(pool * weight, 2)
            priority = "essential" if cat_name in ("food", "transport", "bills") else "flexible"
            if cat_name == "emergency":
                priority = "savings"
            allocations.append(BudgetAllocation(
                category=cat_name,
                allocated=amt,
                percentage=round(weight * 100, 1),
                priority=priority,
            ))
        # Add the savings row
        allocations.append(BudgetAllocation(
            category="savings",
            allocated=round(recommended_savings, 2),
            percentage=round((recommended_savings / income) * 100, 1) if income else 0,
            priority="savings",
        ))

        # ── Upcoming special expenses ─────────────────────────────────────
        if data.upcoming_special_expenses:
            total_special = sum(e.amount for e in data.upcoming_special_expenses)
            if total_special > actual_surplus:
                warnings.append(
                    f"Upcoming special expenses (${total_special:.2f}) "
                    f"exceed your weekly surplus."
                )
            suggestions.append(
                f"Set aside ${total_special:.2f} this week for upcoming costs."
            )

        # ── General tips ──────────────────────────────────────────────────
        if total_variable > disposable * DISCRETIONARY_SPENDING_CAP:
            suggestions.append("Variable expenses are high. Try meal-prepping or carpooling.")
        if total_fixed > income * ESSENTIAL_SPENDING_CAP:
            suggestions.append("Fixed expenses dominate your income. Review subscriptions or negotiate bills.")

        return WeeklyBudgetResult(
            total_income=income,
            total_fixed_expenses=total_fixed,
            total_variable_expenses=total_variable,
            total_expenses=total_expenses,
            disposable_income=round(disposable, 2),
            recommended_savings=round(recommended_savings, 2),
            recommended_essentials_budget=round(recommended_essentials, 2),
            recommended_flexible_budget=round(recommended_flexible, 2),
            category_allocations=allocations,
            warnings=warnings,
            suggestions=suggestions,
            budget_status=status,
        )

rule_budget_service = RuleBasedBudgetService()
