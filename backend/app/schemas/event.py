from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class EventCreate(BaseModel):
    title: str = Field(min_length=2, max_length=120)
    description: Optional[str] = None
    event_date: datetime
    end_date: Optional[datetime] = None
    location: Optional[str] = None
    status: str = "planned"
    spent_amount: float = Field(ge=0, default=0)
    budget_amount: float = Field(gt=0)
    icon: int = 0
    icon_color: int = 0


class EventUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=2, max_length=120)
    description: Optional[str] = None
    event_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    location: Optional[str] = None
    status: Optional[str] = None
    spent_amount: Optional[float] = Field(default=None, ge=0)
    budget_amount: Optional[float] = Field(default=None, gt=0)
    icon: Optional[int] = None
    icon_color: Optional[int] = None


class EventOut(BaseModel):
    id: str
    user_id: str
    title: str
    description: Optional[str] = None
    event_date: datetime
    end_date: Optional[datetime] = None
    location: Optional[str] = None
    status: str
    spent_amount: float
    budget_amount: float
    icon: int
    icon_color: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class EventListResponse(BaseModel):
    events: List[EventOut]


class EventResponse(BaseModel):
    event: EventOut


class EventDeleteResponse(BaseModel):
    success: bool

