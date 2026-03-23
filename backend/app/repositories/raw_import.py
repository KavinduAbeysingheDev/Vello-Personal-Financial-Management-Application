from app.repositories.base import BaseRepository
from typing import Optional, Dict, Any

class RawImportRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "raw_imports")

    async def exists(self, user_id: str, source_type: str, external_id: str) -> bool:
        response = self.client.table(self.table_name).select("id") \
            .eq("user_id", user_id) \
            .eq("source_type", source_type) \
            .eq("external_id", external_id).execute()
        return len(response.data) > 0
