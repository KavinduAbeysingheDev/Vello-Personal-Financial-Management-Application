from pydantic import BaseModel, Field, field_validator
from typing import List, Optional, Dict
from datetime import date

class SpendingCategory(BaseModel):
    name: str
    amount: float = 0.0

class EventPlannerInput(BaseModel):
    title: str
    target_amount: float = Field(gt=0, description="Total budget needed for the event")
    current_saved_amount: float = Field(ge=0, default=0.0)
    event_date: date
    monthly_income: float = Field(ge=0)
    monthly_expenses: float = Field(ge=0)
    spending_categories: Optional[List[SpendingCategory]] = None
    notes: Optional[str] = None

    @field_validator("event_date")
    @classmethod
    def event_date_must_be_future(cls, v):
        if v <= date.today():
            raise ValueError("Event date must be in the future")
        return v

class EventPlannerResult(BaseModel):
    title: str
    target_amount: float
    current_saved_amount: float
    remaining_amount: float
    days_left: int
    weeks_left: float
    months_left: float
    required_daily_saving: float
    required_weekly_saving: float
    required_monthly_saving: float
    monthly_surplus: float
    affordability_status: str  # on_track | possible_with_adjustments | high_risk | not_feasible
    recommendations: List[str]
    warnings: List[str]
