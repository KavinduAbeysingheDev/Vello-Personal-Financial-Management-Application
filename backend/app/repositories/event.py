from typing import Dict, Any, List

from app.repositories.base import BaseRepository


class EventRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "events")

    async def get_user_events(self, user_id: str) -> List[Dict[str, Any]]:
        response = (
            self.client.table(self.table_name)
            .select("*")
            .eq("user_id", user_id)
            .order("event_date", desc=True)
            .execute()
        )
        return response.data

    async def create_user_event(self, user_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        payload = {**data, "user_id": user_id}
        response = self.client.table(self.table_name).insert(payload).execute()
        return response.data[0]

    async def update_user_event(self, user_id: str, event_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        response = (
            self.client.table(self.table_name)
            .update(data)
            .eq("id", event_id)
            .eq("user_id", user_id)
            .execute()
        )
        if not response.data:
            raise ValueError("Event not found")
        return response.data[0]

    async def delete_user_event(self, user_id: str, event_id: str) -> bool:
        response = (
            self.client.table(self.table_name)
            .delete()
            .eq("id", event_id)
            .eq("user_id", user_id)
            .execute()
        )
        return bool(response.data)

