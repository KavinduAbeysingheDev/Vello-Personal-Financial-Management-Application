from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime

class GmailConnectStartResponse(BaseModel):
    auth_url: str

class GmailConnectCallbackResponse(BaseModel):
    email: EmailStr
    status: str

class GmailSyncSummary(BaseModel):
    status: str
    scanned: int
    imported: int
    skipped: int
    failed: int
    message: str
