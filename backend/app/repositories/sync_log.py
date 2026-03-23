from app.repositories.base import BaseRepository

class SyncLogRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "sync_logs")
