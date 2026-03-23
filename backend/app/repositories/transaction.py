from app.repositories.base import BaseRepository
from typing import List, Dict, Any, Optional

class TransactionRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "transactions")

    async def get_user_transactions(self, user_id: str, limit: int = 50, category: Optional[str] = None) -> List[Dict[str, Any]]:
        query = self.client.table(self.table_name).select("*").eq("user_id", user_id)
        if category:
            query = query.eq("category", category)
        response = query.order("transaction_date", desc=True).limit(limit).execute()
        return response.data
