from pydantic import BaseModel, Field
from typing import List, Optional, Dict

class ExpenseItem(BaseModel):
    name: str
    amount: float = Field(ge=0)

class WeeklyBudgetInput(BaseModel):
    weekly_income: float = Field(gt=0)
    fixed_expenses: List[ExpenseItem] = []
    variable_expenses: List[ExpenseItem] = []
    savings_goal: float = Field(ge=0, default=0.0)
    custom_categories: Optional[List[str]] = None
    upcoming_special_expenses: Optional[List[ExpenseItem]] = None

class BudgetAllocation(BaseModel):
    category: str
    allocated: float
    percentage: float
    priority: str  # essential | savings | flexible | discretionary

class WeeklyBudgetResult(BaseModel):
    total_income: float
    total_fixed_expenses: float
    total_variable_expenses: float
    total_expenses: float
    disposable_income: float
    recommended_savings: float
    recommended_essentials_budget: float
    recommended_flexible_budget: float
    category_allocations: List[BudgetAllocation]
    warnings: List[str]
    suggestions: List[str]
    budget_status: str  # healthy | manageable | tight | overspending
