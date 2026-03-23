from app.repositories.base import BaseRepository
from typing import Optional, Dict, Any

class ConnectedAccountRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "connected_accounts")

    async def get_by_provider_email(self, user_id: str, provider: str, email: str) -> Optional[Dict[str, Any]]:
        response = self.client.table(self.table_name).select("*") \
            .eq("user_id", user_id) \
            .eq("provider", provider) \
            .eq("provider_email", email).execute()
        return response.data[0] if response.data else None

    async def upsert_account(self, data: Dict[str, Any]) -> Dict[str, Any]:
        # Simple upsert logic using provider_email and user_id as constraints
        response = self.client.table(self.table_name).upsert(data, on_conflict="user_id,provider,provider_email").execute()
        return response.data[0]
