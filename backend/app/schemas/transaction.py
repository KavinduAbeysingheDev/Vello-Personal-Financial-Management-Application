from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID

class TransactionBase(BaseModel):
    title: str
    amount: float
    category: Optional[str] = None
    transaction_date: datetime
    merchant: Optional[str] = "Unknown"
    currency: str = "LKR"
    source_type: str  # 'sms' or 'gmail'
    external_id: str
    confidence_score: float = 1.0

class TransactionCreate(TransactionBase):
    user_id: str
    raw_import_id: Optional[UUID] = None

class TransactionResponse(TransactionBase):
    id: UUID
    user_id: str
    created_at: datetime

class SyncLogBase(BaseModel):
    user_id: str
    source_type: str
    status: str
    summary: dict
    error_details: Optional[str] = None

class SyncLogResponse(SyncLogBase):
    id: UUID
    created_at: datetime
