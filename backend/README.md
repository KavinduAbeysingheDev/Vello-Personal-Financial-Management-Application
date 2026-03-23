# Vello Backend (Python/FastAPI)

Modular FastAPI backend for transaction synchronization from SMS and Gmail.

## Architecture
- **FastAPI**: Modern, fast web framework for APIs.
- **Supabase**: Primary database and authentication (using `supabase-py`).
- **Google OAuth / Gmail API**: Secure email harvesting.
- **Pydantic**: Strict data validation and settings management.

## Project Structure
```text
backend/
  app/
    api/v1/           # API versioning and endpoints
    core/             # Config, security, and global clients
    models/           # (Reserved for ORM if needed)
    repositories/     # Supabase database access layer
    schemas/          # Pydantic request/response models
    services/         # Business logic (Parser, Sync, OAuth)
    main.py           # Application entry point
  requirements.txt    # Dependencies
  .env.example        # Environment template
  schema.sql          # Supabase database schema
```

## Setup Instructions

1. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure Environment**:
   - Copy `.env.example` to `.env`.
   - Update `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY`.
   - Add your Google `CLIENT_ID` and `CLIENT_SECRET` from the [Google Cloud Console](https://console.cloud.google.com/).

3. **Run the Application**:
   ```bash
   uvicorn app.main:app --reload
   ```
   The API will be available at `http://localhost:8000`.

4. **API Documentation**:
   - Swagger UI: `http://localhost:8000/docs`
   - ReDoc: `http://localhost:8000/redoc`

## Endpoints Summary
- `POST /api/v1/sms/import`: Import normalized SMS data from the Flutter app.
- `GET /api/v1/gmail/connect/start`: Initiate Google OAuth flow.
- `POST /api/v1/gmail/sync`: Trigger a background sync for the connected account.
- `GET /api/v1/transactions`: Retrieve cloud transactions with filtering.
