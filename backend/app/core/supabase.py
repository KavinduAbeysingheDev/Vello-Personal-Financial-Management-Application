from supabase import create_client, Client
from app.core.config import settings
from typing import Optional

_supabase_client: Optional[Client] = None

def get_supabase() -> Client:
    """Lazy-load the Supabase client. Only connects when first called."""
    global _supabase_client
    if _supabase_client is None:
        if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
            raise RuntimeError(
                "Supabase is not configured. "
                "Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in your .env file."
            )
        _supabase_client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)
    return _supabase_client
