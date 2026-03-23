import json
from google_auth_oauthlib.flow import Flow
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from app.core.config import settings
from typing import Dict, Any, Optional

class GoogleAuthService:
    SCOPES = ['https://www.googleapis.com/auth/gmail.readonly', 'email', 'openid']

    def get_auth_url(self) -> str:
        flow = Flow.from_client_config(
            self._get_client_config(),
            scopes=self.SCOPES,
            redirect_uri=settings.GOOGLE_REDIRECT_URI
        )
        auth_url, _ = flow.authorization_url(prompt='consent', access_type='offline')
        return auth_url

    async def get_credentials(self, code: str) -> Credentials:
        flow = Flow.from_client_config(
            self._get_client_config(),
            scopes=self.SCOPES,
            redirect_uri=settings.GOOGLE_REDIRECT_URI
        )
        flow.fetch_token(code=code)
        return flow.credentials

    def _get_client_config(self) -> Dict[str, Any]:
        return {
            "web": {
                "client_id": settings.GOOGLE_CLIENT_ID,
                "project_id": "vello-app",
                "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                "token_uri": "https://oauth2.googleapis.com/token",
                "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
                "client_secret": settings.GOOGLE_CLIENT_SECRET,
                "redirect_uris": [settings.GOOGLE_REDIRECT_URI]
            }
        }

google_auth_service = GoogleAuthService()
