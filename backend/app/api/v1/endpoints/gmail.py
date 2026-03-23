from fastapi import APIRouter, Depends, HTTPException, Query
from app.services.google_auth_service import google_auth_service
from app.services.gmail_service import gmail_service
from app.repositories.connected_account import ConnectedAccountRepository
from app.repositories.sync_log import SyncLogRepository
from app.schemas.gmail import GmailConnectStartResponse, GmailSyncSummary
from app.core.supabase import get_supabase
from app.core.config import settings

router = APIRouter()

def get_account_repo():
    return ConnectedAccountRepository(get_supabase())

def get_sync_log_repo():
    return SyncLogRepository(get_supabase())

@router.get("/connect/start", response_model=GmailConnectStartResponse)
async def connect_start():
    auth_url = google_auth_service.get_auth_url()
    return {"auth_url": auth_url}

@router.get("/callback")
async def connect_callback(
    code: str,
    user_id: str = Query(...), # Passed back via state or direct query in local dev
    repo: ConnectedAccountRepository = Depends(get_account_repo)
):
    try:
        creds = await google_auth_service.get_credentials(code)
        
        # Store in Supabase
        account_data = {
            "user_id": user_id,
            "provider": "gmail",
            "provider_email": "user@gmail.com", # Should fetch from id_token or service
            "access_token": creds.token,
            "refresh_token": creds.refresh_token,
            "expires_at": creds.expiry.isoformat() if creds.expiry else None,
            "status": "connected",
            "access_scope": "gmail.readonly",
            "client_id": settings.GOOGLE_CLIENT_ID,
            "client_secret": settings.GOOGLE_CLIENT_SECRET
        }
        
        await repo.upsert_account(account_data)
        
        return {"status": "success", "message": "Gmail connected successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/sync", response_model=GmailSyncSummary)
async def sync_gmail(
    user_id: str,
    days: int = Query(7, gt=0, le=30),
    sync_repo: SyncLogRepository = Depends(get_sync_log_repo)
):
    try:
        summary = await gmail_service.sync_user_gmail(user_id, days)
        
        # Log success
        await sync_repo.create({
            "user_id": user_id,
            "source_type": "gmail",
            "status": "success",
            "summary": summary
        })
        
        return {
            "status": "success",
            "message": "Gmail sync completed",
            **summary
        }
    except Exception as e:
        # Log failure
        await sync_repo.create({
            "user_id": user_id,
            "source_type": "gmail",
            "status": "failed",
            "summary": {"message": str(e)},
            "error_details": str(e)
        })
        raise HTTPException(status_code=500, detail=str(e))
