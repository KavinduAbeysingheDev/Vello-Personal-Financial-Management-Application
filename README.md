# Vello-Personal-Financial-Management-Application
# Vello – Personal Financial Management Application
# vello_app

Vello is a personal financial management application developed as part of the **SDGP (Software Development Group Project)**.  
The application helps users track income and expenses, manage budgets, and gain clear insights into their financial habits through an intuitive and user-friendly interface.

---

## 🚀 Features

- User registration and secure login
- Add, update, and delete income and expense records
- Categorize transactions (Food, Transport, Bills, Entertainment, etc.)
- Monthly and yearly financial summaries
- Budget planning and tracking
- Visual reports (charts and graphs)
- Data persistence using a database
- Responsive and user-friendly UI

---

## 🛠️ Technologies Used

- **Frontend**: HTML, CSS, JavaScript  
- **Backend**: (e.g., Java / Node.js / Python – update as applicable)  
- **Database**: MySQL / MongoDB / SQLite  
- **Version Control**: Git & GitHub  
- **IDE**: Visual Studio Code  

> ✏️ *Update the technology stack if your project uses different tools.*

---

## 📁 Project Structure

Vello/
│
├── README.md                 # Project overview and setup instructions
├── .gitignore                # Files/folders ignored by Git
├── package.json / pom.xml    # Dependency & project config (based on tech stack)
│
├── src/                      # Main source code
│   ├── config/               # App & database configuration
│   │   └── dbConfig.js
│   │
│   ├── controllers/          # Request handling logic
│   │   ├── authController.js
│   │   ├── transactionController.js
│   │   └── budgetController.js
│   │
│   ├── models/               # Data models / entities
│   │   ├── User.js
│   │   ├── Transaction.js
│   │   └── Budget.js
│   │
│   ├── routes/               # Application routes / APIs
│   │   ├── authRoutes.js
│   │   ├── transactionRoutes.js
│   │   └── budgetRoutes.js
│   │
│   ├── services/             # Business logic layer
│   │   └── financeService.js
│   │
│   ├── middlewares/          # Authentication & validation middleware
│   │   └── authMiddleware.js
│   │
│   ├── utils/                # Helper functions
│   │   └── dateUtils.js
│   │
│   └── app.js                # Main application entry point
│
├── public/                   # Frontend static files
│   ├── index.html
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── main.js
│   └── images/
│
├── database/                 # Database-related files
│   ├── schema.sql            # Database schema
│   └── seed.sql              # Sample data
│
├── tests/                    # Test cases
│   ├── unit/
│   └── integration/
│
├── docs/                     # SDGP documentation
│   ├── SRS.pdf
│   ├── Design_Diagrams/
│   └── Test_Plan.pdf
│
└── logs/                     # Application logs
    └── app.log

#License

MIT License

Copyright (c) 2026 Vello Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
