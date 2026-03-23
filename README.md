Vello – AI-Powered Personal Finance Management Application

Project Overview

In Sri Lanka, managing personal finances remains a significant challenge for young professionals, university students, and middle-income families. The absence of locally relevant, intelligent, and accessible financial management tools leads to poor expense tracking, unplanned overspending, and low financial literacy. Existing global applications fail to account for Sri Lanka's unique cultural context, including local festival spending patterns, multilingual user needs, and the prevalence of cash-based and SMS-based transactions.

Vello is an AI-powered personal finance management mobile application designed to address these challenges by providing Sri Lankan users with an intelligent, offline-capable, and culturally aware platform for tracking expenses, managing budgets, and achieving financial goals.



Objectives

- Provide a simple and accessible platform for real-time income and expense tracking
- Automate expense entry through OCR-based receipt scanning and SMS/Gmail bill detection
- Deliver AI-powered financial insights, spending analysis, and budget recommendations
- Enable users to set and track savings goals and event-based budgets
- Support trilingual accessibility in English, Sinhala, and Tamil
- Ensure user data security and privacy compliance with Sri Lankan regulations

---

Key Features

Financial Tracking
- Manual income and expense entry with category assignment
- Real-time balance updates and savings rate calculation
- Colour-coded budget progress indicators per spending category

Smart Bill Scanner
- OCR-powered receipt scanning using Google ML Kit
- Multi-photo support for long or multi-page bills
- Automatic item extraction and expense categorisation

AI Finance Assistant
- Conversational AI assistant for spending analysis and budget checks
- Real-time category breakdown and savings rate reporting
- Personalised savings tips and weekly financial summaries

Statistics & Analytics
- Interactive donut chart with category-level spending breakdown
- Weekly and monthly view toggle
- Income, spent, and saved summary cards

Savings Goals
- Named savings goals with target amounts, deadlines, and priority levels
- Animated progress bars with aggregate total progress tracking
- Add funds functionality with remaining amount display

Event Planner
- Flexible budget planner for any occasion or celebration
- Per-event spending tracking with remaining budget display
- Total event budget summary across all active events

Auto Bill Detection
- Automatic expense extraction from SMS and Gmail notifications
- Background parsing of financial keywords without manual input

Accessibility & Localisation
- Trilingual interface supporting English, Sinhala, and Tamil
- Dark and light mode support
- Designed for diverse Sri Lankan demographics including students, professionals, and families

Security & Privacy
- Secure authentication via Firebase Authentication
- Encrypted cloud data storage via Firebase Firestore
- Compliance with the Sri Lanka Personal Data Protection Act
- On-device OCR processing to protect sensitive receipt data

---

System Architecture

- **Frontend:** Flutter (Android & iOS) with MVVM architecture
- **Backend & Database:** Firebase Firestore (cloud), local storage for offline support
- **Authentication:** Firebase Authentication
- **OCR Engine:** Google ML Kit (on-device processing)
- **AI Module:** Rule-based AI engine for budget recommendations and spending analysis
- **Design & Prototyping:** Figma
- **Project Management:** ClickUp, Google Workspace

---

 Methodology
 
The system was developed following:

- User surveys and questionnaire-based requirement elicitation (55 respondents)
- Stakeholder analysis using an Onion Model
- Agile Scrum development methodology with iterative sprint cycles
- Human-Centred Design (HCD) principles for UI/UX
- Object-Oriented Analysis and Design (OOAD) with MVVM architecture
- Usability testing and post-interaction evaluation

---

Preliminary Results

Initial findings from user surveys, stakeholder analysis, and usability testing indicate that Vello significantly improves:

- Ease of daily expense tracking through automation and OCR scanning
- Financial awareness through real-time dashboards and AI-driven insights
- Budget discipline through colour-coded visual feedback and spending alerts
- Savings motivation through goal tracking and progress visualisation
- Cultural relevance through trilingual support and event-based budget planning

Collectively, these outcomes demonstrate that Vello provides a scalable, intelligent, and culturally relevant solution that supports improved financial literacy, reduced overspending, and confident financial decision-making among Sri Lankan users.

---

Future Enhancements

- Integration with banking APIs through Open Banking standards for real-time transaction sync
- Web and desktop version of the application
- Voice-based expense entry using speech-to-text and NLP
- Gamification features including achievement badges and streak rewards
- Expanded language support for additional South Asian markets
- Investment tracking and credit score monitoring

---

Technology Stack

### Mobile
- **Flutter** – Cross-platform mobile framework for Android and iOS
- **Dart** – Primary programming language

### Backend & Database
- **Firebase Authentication** – Secure user authentication and session management
- **Firebase Firestore** – Real-time cloud NoSQL database with offline support

### AI & OCR
- **Google ML Kit** – On-device Optical Character Recognition for receipt scanning
- **Rule-based AI Engine** – Custom financial analysis and budget recommendation logic

### Design & Collaboration
- **Figma** – UI/UX design and high-fidelity prototyping
- **ClickUp** – Sprint planning and task management
- **Google Workspace** – Documentation and team collaboration
- **Git & GitHub** – Version control and code management

### Security
- Firebase Authentication with encrypted credentials
- On-device OCR processing for receipt privacy
- Compliance with Sri Lanka Personal Data Protection Act

---

Development Team — CS-113

| Name | Role | UoW ID | IIT ID |
|------|------|--------|--------|
| W.M.K.S. Abeysinghe | Developer | w2153025 | 20241210 |
| W.A.C.D. Wijesinghe | Developer | w2151956 | 20241938 |
| E.M.M.W.J.A. Ekanayake | Developer | w2151909 | 20241673 |
| K.D.A. Abhiman | Developer | w2153543 | 20231387 |
| H.K.D. Mayumi Bhagya | Developer | w2153592 | 20241600 |
| W.K. Ransini Laknara Rathnasiri | Developer | w2052289 | 20221014 |

---

Academic Information

| | |
|---|---|
| **Module** | Software Development Group Project |
| **Module Code** | 5COSC021C |
| **Module Leader** | Mr. Banuka Athuraliya |
| **Group Supervisor** | Mr. Janith Prabhamuka |
| **Institution** | Informatics Institute of Technology (IIT) |
| **University** | University of Westminster, UK |
| **Academic Year** | 2025/26 |

---
License

This project is developed for academic purposes as part of the Software Development Group Project (SDGP) module at the Informatics Institute of Technology (IIT), Sri Lanka.  
All rights reserved 
2026 Team Vello — CS-113
