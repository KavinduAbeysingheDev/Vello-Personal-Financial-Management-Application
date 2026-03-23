from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class SmsMessageBase(BaseModel):
    sms_id: str
    sender: str
    body: str
    timestamp: datetime

class SmsImportRequest(BaseModel):
    user_id: str
    messages: List[SmsMessageBase]

class SmsImportSummary(BaseModel):
    total_scanned: int
    total_matched: int
    total_inserted: int
    total_skipped: int
    errors: Optional[List[str]] = None
