from fastapi import APIRouter, Depends, HTTPException
from app.schemas.sms import SmsImportRequest, SmsImportSummary
from app.services.sms_service import sms_parser
from app.repositories.raw_import import RawImportRepository
from app.repositories.transaction import TransactionRepository
from app.repositories.sync_log import SyncLogRepository
from app.core.supabase import get_supabase
from typing import List

router = APIRouter()

# Dependency injection for repositories
def get_raw_import_repo():
    return RawImportRepository(get_supabase())

def get_transaction_repo():
    return TransactionRepository(get_supabase())

def get_sync_log_repo():
    return SyncLogRepository(get_supabase())

@router.post("/import", response_model=SmsImportSummary)
async def import_sms(
    request: SmsImportRequest,
    raw_repo: RawImportRepository = Depends(get_raw_import_repo),
    trans_repo: TransactionRepository = Depends(get_transaction_repo),
    sync_repo: SyncLogRepository = Depends(get_sync_log_repo)
):
    summary = {
        "total_scanned": len(request.messages),
        "total_matched": 0,
        "total_inserted": 0,
        "total_skipped": 0,
        "errors": []
    }
    
    try:
        inserted_raw_ids = []
        for msg in request.messages:
            # 1. Deduplication check
            if await raw_repo.exists(request.user_id, "sms", msg.sms_id):
                summary["total_skipped"] += 1
                continue
                
            # 2. Parse SMS
            transaction_data = sms_parser.parse_sms_transaction(request.user_id, msg)
            if not transaction_data:
                continue
            
            summary["total_matched"] += 1
            
            # 3. Store Raw Import First
            raw_data = {
                "user_id": request.user_id,
                "source_type": "sms",
                "external_id": msg.sms_id,
                "sender": msg.sender,
                "raw_text": msg.body,
                "transaction_date": msg.timestamp.isoformat(),
                "metadata": {"sender": msg.sender}
            }
            raw_import = await raw_repo.create(raw_data)
            
            # 4. Store Transaction
            transaction_dict = transaction_data.model_dump()
            transaction_dict["raw_import_id"] = raw_import["id"]
            await trans_repo.create(transaction_dict)
            
            summary["total_inserted"] += 1

        # 5. Log Sync
        await sync_repo.create({
            "user_id": request.user_id,
            "source_type": "sms",
            "status": "success",
            "summary": summary
        })
        
        return summary

    except Exception as e:
        # Log failure
        await sync_repo.create({
            "user_id": request.user_id,
            "source_type": "sms",
            "status": "failed",
            "summary": summary,
            "error_details": str(e)
        })
        raise HTTPException(status_code=500, detail=str(e))
