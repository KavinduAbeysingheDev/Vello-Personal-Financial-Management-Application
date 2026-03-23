# Vello AI Chatbot Backend

A **rule-based AI chatbot backend** for the Vello personal financial management application, built with **Dart** and the **Shelf** HTTP framework.

## Features

- **Spending Analysis** — Breakdown by category with percentages and anomaly detection
- **Budget Recommendations** — 50/30/20 rule with visual progress bars
- **Weekly Summary** — Income, expenses, daily averages, budget adherence
- **Savings Tips** — Personalized tips based on spending patterns
- **Financial Health Score** — 0-100 score with detailed metric breakdown
- **Balance Check** — Account overview with savings goal progress
- **Category Breakdown** — Per-category expense details
- **Spending Comparison** — Month-over-month trend analysis
- **Quick Replies** — Context-aware suggested actions (chips)

## Architecture

```
User Message → Rule Engine (Intent Classification)
                    ↓
            Intent Router (ChatbotService)
                    ↓
        Financial Analysis Services
                    ↓
        Formatted Response + Quick Replies
```

## Getting Started

### Prerequisites
- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0

### Install Dependencies
```bash
cd Back
dart pub get
```

### Run the Server
```bash
dart run bin/server.dart
```
The server starts on `http://localhost:8080`.

### Run Tests
```bash
dart test
```

## API Endpoints

### POST /api/chat
Send a message to the chatbot.

**Request:**
```json
{
  "message": "Analyze my spending",
  "userId": "user_001"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "bot_1710...",
    "text": "📊 **Spending Analysis**\n...",
    "isUser": false,
    "timestamp": "2026-03-15T...",
    "quickReplies": [
      "Budget recommendations",
      "Compare with last month",
      "Savings tips",
      "Financial health score"
    ],
    "metadata": {
      "intent": "analyzeSpending",
      "confidence": 0.95,
      "entities": {}
    }
  }
}
```

### GET /api/chat/health
Health check endpoint.

### GET /api/chat/quick-replies
Get default quick-reply options.

## Supported Intents

| Intent | Example Phrases |
|--------|----------------|
| Spending Analysis | "Analyze my spending", "Where is my money going?" |
| Budget Recommendations | "Budget recommendations", "Help me budget" |
| Weekly Summary | "Weekly summary", "How was my week?" |
| Savings Tips | "Savings tips", "How can I save more?" |
| Financial Health | "Financial health score", "Rate my finances" |
| Balance Check | "Check my balance", "How much do I have?" |
| Category Breakdown | "How much on food?", "Show transport expenses" |
| Compare Spending | "Compare my spending", "Am I spending more?" |
| Greeting | "Hello", "Hi there" |
| Help | "What can you do?", "Help me" |

## Project Structure

```
Back/
├── bin/
│   └── server.dart                        # HTTP server entry point
├── lib/
│   ├── models/                            # Data models
│   │   ├── category.dart
│   │   ├── transaction.dart
│   │   ├── budget.dart
│   │   ├── chat_message.dart
│   │   └── user_profile.dart
│   ├── services/                          # Business logic
│   │   ├── chatbot_service.dart           # Main orchestrator
│   │   ├── rule_engine.dart               # Intent classification
│   │   ├── spending_analysis_service.dart
│   │   ├── budget_service.dart
│   │   ├── savings_service.dart
│   │   ├── weekly_summary_service.dart
│   │   └── financial_health_service.dart
│   ├── controllers/
│   │   └── chat_controller.dart           # HTTP request handlers
│   ├── data/
│   │   ├── rule_definitions.dart          # Intent rules & keywords
│   │   ├── tips_data.dart                 # Financial tips database
│   │   └── sample_data.dart               # Demo data
│   └── utils/
│       ├── constants.dart
│       └── formatters.dart
├── test/
│   ├── rule_engine_test.dart
│   └── chatbot_service_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── .gitignore
```

## Tech Stack

- **Language:** Dart 3.x
- **HTTP Framework:** Shelf + Shelf Router
- **CORS:** shelf_cors_headers
- **Testing:** Dart test package
