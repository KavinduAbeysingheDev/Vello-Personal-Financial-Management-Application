from fastapi import APIRouter, HTTPException
from app.schemas.event_planner import EventPlannerInput, EventPlannerResult
from app.services.event_planner_service import event_planner_service

router = APIRouter()

@router.post("/calculate", response_model=EventPlannerResult)
async def calculate_event_plan(data: EventPlannerInput):
    try:
        return event_planner_service.calculate(data)
    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Calculation error: {str(e)}")

@router.get("/health")
async def event_planner_health():
    return {"status": "ok", "service": "event-planner"}
