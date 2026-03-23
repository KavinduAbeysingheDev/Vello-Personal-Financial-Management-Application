from googleapiclient.discovery import build
from google.oauth2.credentials import Credentials
from app.repositories.connected_account import ConnectedAccountRepository
from app.repositories.raw_import import RawImportRepository
from app.repositories.transaction import TransactionRepository
from app.services.sms_service import sms_parser
from app.core.supabase import get_supabase
from datetime import datetime, timedelta
import base64

class GmailService:
    async def sync_user_gmail(self, user_id: str, days: int = 7) -> dict:
        summary = {"scanned": 0, "imported": 0, "skipped": 0, "failed": 0}
        
        # Lazy-load Supabase client
        db = get_supabase()
        
        # 1. Get credentials from DB
        account_repo = ConnectedAccountRepository(db)
        accounts = await account_repo.list({"user_id": user_id, "provider": "gmail"})
        if not accounts:
            return {"status": "error", "message": "No Gmail account connected"}
        
        account = accounts[0]
        creds = Credentials(
            token=account.get("access_token"),
            refresh_token=account.get("refresh_token"),
            token_uri="https://oauth2.googleapis.com/token",
            client_id=account.get("client_id"),
            client_secret=account.get("client_secret"),
            scopes=['https://www.googleapis.com/auth/gmail.readonly']
        )
        
        # 2. Build Gmail Service
        service = build('gmail', 'v1', credentials=creds)
        
        # 3. Search for purchase-related emails
        after_date = (datetime.now() - timedelta(days=days)).strftime("%Y/%m/%d")
        query = f'label:inbox (category:purchases OR purchase OR receipt OR payment OR order OR billing) after:{after_date}'
        
        results = service.users().messages().list(userId='me', q=query).execute()
        messages = results.get('messages', [])
        
        raw_repo = RawImportRepository(db)
        trans_repo = TransactionRepository(db)

        for msg_info in messages:
            summary["scanned"] += 1
            msg_id = msg_info['id']
            
            # Deduplication
            if await raw_repo.exists(user_id, "gmail", msg_id):
                summary["skipped"] += 1
                continue
                
            # Fetch message content
            msg = service.users().messages().get(userId='me', id=msg_id).execute()
            snippet = msg.get('snippet', '')
            payload = msg.get('payload', {})
            headers = payload.get('headers', [])
            
            subject = next((h['value'] for h in headers if h['name'] == 'Subject'), 'No Subject')
            sender = next((h['value'] for h in headers if h['name'] == 'From'), 'Unknown')
            
            # 4. Parse content
            transaction_data = sms_parser.is_transaction_message(snippet)
            if not transaction_data:
                continue
            
            # Create Raw Import
            raw_import = await raw_repo.create({
                "user_id": user_id,
                "source_type": "gmail",
                "external_id": msg_id,
                "sender": sender,
                "raw_text": snippet,
                "transaction_date": datetime.now().isoformat(),
                "metadata": {"subject": subject}
            })
            
            # Extract fields
            amount = sms_parser.extract_amount(snippet)
            merchant = sms_parser.extract_merchant(snippet)
            
            # Store Transaction
            await trans_repo.create({
                "user_id": user_id,
                "title": f"{merchant} (Mail)",
                "amount": amount,
                "category": "General",
                "transaction_date": datetime.now().isoformat(),
                "merchant": merchant,
                "currency": "LKR",
                "source_type": "gmail",
                "external_id": msg_id,
                "raw_import_id": raw_import["id"],
                "confidence_score": 0.8
            })
            
            summary["imported"] += 1
            
        return summary

gmail_service = GmailService()
