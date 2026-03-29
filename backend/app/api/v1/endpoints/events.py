from fastapi import APIRouter, Depends, HTTPException

from app.api.deps.auth import get_current_user_id
from app.core.supabase import get_supabase
from app.repositories.event import EventRepository
from app.schemas.event import (
    EventCreate,
    EventDeleteResponse,
    EventListResponse,
    EventOut,
    EventResponse,
    EventUpdate,
)

router = APIRouter()


def _to_db_payload(data: dict) -> dict:
    payload = dict(data)
    if payload.get("event_date") is not None:
        payload["event_date"] = payload["event_date"].isoformat()
    if payload.get("end_date") is not None:
        payload["end_date"] = payload["end_date"].isoformat()
    return payload


def get_event_repo() -> EventRepository:
    return EventRepository(get_supabase())


@router.get("", response_model=EventListResponse)
@router.get("/", response_model=EventListResponse, include_in_schema=False)
async def list_events(
    user_id: str = Depends(get_current_user_id),
    repo: EventRepository = Depends(get_event_repo),
):
    events = await repo.get_user_events(user_id)
    return {"events": events}


@router.post("", response_model=EventResponse)
@router.post("/", response_model=EventResponse, include_in_schema=False)
async def create_event(
    payload: EventCreate,
    user_id: str = Depends(get_current_user_id),
    repo: EventRepository = Depends(get_event_repo),
):
    event = await repo.create_user_event(user_id, _to_db_payload(payload.model_dump()))
    return {"event": event}


@router.put("/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: str,
    payload: EventUpdate,
    user_id: str = Depends(get_current_user_id),
    repo: EventRepository = Depends(get_event_repo),
):
    data = _to_db_payload(payload.model_dump(exclude_unset=True))
    if not data:
        raise HTTPException(status_code=400, detail="No fields to update")

    try:
        event = await repo.update_user_event(user_id, event_id, data)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    return {"event": event}


@router.delete("/{event_id}", response_model=EventDeleteResponse)
async def delete_event(
    event_id: str,
    user_id: str = Depends(get_current_user_id),
    repo: EventRepository = Depends(get_event_repo),
):
    deleted = await repo.delete_user_event(user_id, event_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Event not found")
    return {"success": True}
