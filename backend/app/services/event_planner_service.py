from datetime import date
from app.schemas.event_planner import EventPlannerInput, EventPlannerResult

class EventPlannerService:

    @staticmethod
    def calculate(data: EventPlannerInput) -> EventPlannerResult:
        warnings: list[str] = []
        recommendations: list[str] = []

        remaining = data.target_amount - data.current_saved_amount
        if remaining <= 0:
            remaining = 0

        delta = data.event_date - date.today()
        days_left = max(delta.days, 1)         # avoid division by zero
        weeks_left = round(days_left / 7, 1)
        months_left = round(days_left / 30, 1)

        daily_saving = round(remaining / days_left, 2) if remaining > 0 else 0
        weekly_saving = round(remaining / max(weeks_left, 0.1), 2) if remaining > 0 else 0
        monthly_saving = round(remaining / max(months_left, 0.1), 2) if remaining > 0 else 0

        surplus = data.monthly_income - data.monthly_expenses

        # ── Affordability assessment ──────────────────────────────────────
        if remaining <= 0:
            status = "on_track"
            recommendations.append("You've already saved enough for this event!")
        elif surplus <= 0:
            status = "not_feasible"
            warnings.append("Your monthly expenses exceed your income. You have no surplus to save.")
            recommendations.append("Reduce monthly spending before planning this event.")
            recommendations.append("Consider a smaller event budget or postpone the date.")
        elif monthly_saving <= surplus * 0.5:
            status = "on_track"
            recommendations.append(f"Save ${daily_saving:.2f}/day or ${weekly_saving:.2f}/week to stay on track.")
        elif monthly_saving <= surplus:
            status = "possible_with_adjustments"
            recommendations.append(f"You need to save ${monthly_saving:.2f}/month — that's most of your surplus.")
            recommendations.append("Cut discretionary spending (dining out, entertainment) to make room.")
        elif monthly_saving <= surplus * 1.5:
            status = "high_risk"
            warnings.append("Reaching this target requires saving more than your current surplus.")
            recommendations.append("Increase income or significantly reduce expenses.")
            recommendations.append("Consider extending the event date to ease the saving pressure.")
        else:
            status = "not_feasible"
            warnings.append("This goal is unrealistic with current finances.")
            recommendations.append(f"You'd need ${monthly_saving:.2f}/month but only have ${surplus:.2f} surplus.")
            recommendations.append("Lower the target amount or push the event date further out.")

        # General tips when there IS a surplus
        if surplus > 0 and remaining > 0:
            if data.spending_categories:
                discretionary = [c for c in data.spending_categories
                                 if c.name.lower() in ("entertainment", "dining", "shopping", "personal")]
                if discretionary:
                    total_disc = sum(c.amount for c in discretionary)
                    recommendations.append(
                        f"Your discretionary spending is ${total_disc:.2f}/month. "
                        f"Reducing it by 20% saves an extra ${total_disc * 0.2:.2f}."
                    )

        return EventPlannerResult(
            title=data.title,
            target_amount=data.target_amount,
            current_saved_amount=data.current_saved_amount,
            remaining_amount=remaining,
            days_left=days_left,
            weeks_left=weeks_left,
            months_left=months_left,
            required_daily_saving=daily_saving,
            required_weekly_saving=weekly_saving,
            required_monthly_saving=monthly_saving,
            monthly_surplus=surplus,
            affordability_status=status,
            recommendations=recommendations,
            warnings=warnings,
        )

event_planner_service = EventPlannerService()
