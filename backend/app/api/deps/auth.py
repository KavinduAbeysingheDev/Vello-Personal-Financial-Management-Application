from fastapi import Header, HTTPException
from app.core.supabase import get_supabase


async def get_current_user_id(authorization: str = Header(default=None)) -> str:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")

    token = authorization.split(" ", 1)[1].strip()
    if not token:
        raise HTTPException(status_code=401, detail="Invalid bearer token")

    try:
        supabase = get_supabase()
        user_resp = supabase.auth.get_user(jwt=token)
        user = getattr(user_resp, "user", None)
        user_id = getattr(user, "id", None)
        if not user_id:
            raise HTTPException(status_code=401, detail="Unauthorized")
        return user_id
    except RuntimeError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=401, detail="Unauthorized")
