import re
from datetime import datetime
from typing import Optional, Dict, Any, List
from app.schemas.sms import SmsMessageBase
from app.schemas.transaction import TransactionCreate

class SmsParserService:
    # Regex patterns for Sri Lankan banks (LKR focus)
    AMOUNT_PATTERN = r"(?:Rs\.?|LKR)\s?([\d,]+\.?\d*)"
    MERCHANT_PATTERNS = [
        r"at\s+([^,.\n]+)",
        r"to\s+([^,.\n]+)",
        r"paid\s+to\s+([^,.\n]+)",
        r"from\s+([^,.\n]+)"
    ]
    
    TRANSACTION_KEYWORDS = [
        "rs", "lkr", "debited", "spent", "purchased", 
        "paid", "payment", "txn", "transaction", "credited"
    ]

    def is_transaction_message(self, text: str) -> bool:
        text_lower = text.lower()
        return any(keyword in text_lower for keyword in self.TRANSACTION_KEYWORDS)

    def extract_amount(self, text: str) -> float:
        match = re.search(self.AMOUNT_PATTERN, text, re.IGNORECASE)
        if match:
            amount_str = match.group(1).replace(",", "")
            try:
                return float(amount_str)
            except ValueError:
                return 0.0
        return 0.0

    def extract_merchant(self, text: str) -> str:
        for pattern in self.MERCHANT_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        return "Unknown"

    def parse_sms_transaction(self, user_id: str, message: SmsMessageBase) -> Optional[TransactionCreate]:
        if not self.is_transaction_message(message.body):
            return None

        amount = self.extract_amount(message.body)
        merchant = self.extract_merchant(message.body)
        
        # Determine category based on merchant or keywords (Simplified)
        category = "General"
        if any(kw in merchant.lower() for kw in ["super", "market", "keells", "cargills"]):
            category = "Grocery"
        elif any(kw in merchant.lower() for kw in ["fuel", "petrol", "filling"]):
            category = "Transport"

        return TransactionCreate(
            user_id=user_id,
            title=f"{merchant} (SMS)",
            amount=amount,
            category=category,
            transaction_date=message.timestamp,
            merchant=merchant,
            currency="LKR",
            source_type="sms",
            external_id=message.sms_id,
            confidence_score=0.9 if amount > 0 else 0.5
        )

sms_parser = SmsParserService()
