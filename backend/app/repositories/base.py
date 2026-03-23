from typing import Any, Dict, List, Optional, TypeVar, Generic
from supabase import Client
from uuid import UUID

T = TypeVar("T")

class BaseRepository(Generic[T]):
    def __init__(self, client: Client, table_name: str):
        self.client = client
        self.table_name = table_name

    async def get_by_id(self, id: Any) -> Optional[Dict[str, Any]]:
        response = self.client.table(self.table_name).select("*").eq("id", id).execute()
        return response.data[0] if response.data else None

    async def list(self, filters: Dict[str, Any] = None, limit: int = 100) -> List[Dict[str, Any]]:
        query = self.client.table(self.table_name).select("*")
        if filters:
            for key, value in filters.items():
                query = query.eq(key, value)
        response = query.limit(limit).execute()
        return response.data

    async def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
        response = self.client.table(self.table_name).insert(data).execute()
        return response.data[0]

    async def update(self, id: Any, data: Dict[str, Any]) -> Dict[str, Any]:
        response = self.client.table(self.table_name).update(data).eq("id", id).execute()
        return response.data[0]

    async def delete(self, id: Any) -> None:
        self.client.table(self.table_name).delete().eq("id", id).execute()
