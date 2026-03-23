from fastapi import APIRouter
from app.api.v1.endpoints import sms, gmail, transactions, event_planner, rule_ai

api_router = APIRouter()

api_router.include_router(sms.router, prefix="/sms", tags=["sms"])
api_router.include_router(gmail.router, prefix="/gmail", tags=["gmail"])
api_router.include_router(transactions.router, prefix="/transactions", tags=["transactions"])
api_router.include_router(event_planner.router, prefix="/event-planner", tags=["event-planner"])
api_router.include_router(rule_ai.router, prefix="/rule-ai", tags=["rule-ai"])
