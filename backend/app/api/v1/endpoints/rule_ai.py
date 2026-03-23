from fastapi import APIRouter, HTTPException
from app.schemas.weekly_budget import WeeklyBudgetInput, WeeklyBudgetResult
from app.services.rule_budget_service import rule_budget_service

router = APIRouter()

@router.post("/weekly-budget", response_model=WeeklyBudgetResult)
async def generate_weekly_budget(data: WeeklyBudgetInput):
    try:
        return rule_budget_service.generate_plan(data)
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Budget generation error: {str(e)}")

@router.get("/health")
async def rule_ai_health():
    return {"status": "ok", "service": "rule-ai-budget"}
