from fastapi import APIRouter, Depends, Query
from app.schemas.transaction import TransactionResponse
from app.repositories.transaction import TransactionRepository
from app.core.supabase import get_supabase
from typing import List, Optional

router = APIRouter()

def get_transaction_repo():
    return TransactionRepository(get_supabase())

@router.get("/", response_model=List[TransactionResponse])
async def list_transactions(
    user_id: str,
    limit: int = Query(50, gt=0, le=100),
    category: Optional[str] = None,
    repo: TransactionRepository = Depends(get_transaction_repo)
):
    transactions = await repo.get_user_transactions(user_id, limit, category)
    return transactions
