# Spendex (FinTrace) Flutter App - Complete Implementation Plan v2.0

**Date:** February 12, 2026
**Version:** 2.0 (Revised - Comprehensive)
**Status:** Pending Approval
**Backend API:** https://api.spendex.in/api/v1
**Reference:** `.same/plan` (FinTrace v2.0 Master Plan)

---

## 1. Current State Analysis

### 1.1 What's Built & Working

| Feature | Data Layer | Domain Layer | Presentation | DI Registered | Status |
|---------|-----------|-------------|-------------|--------------|--------|
| Auth (Login/Register/OTP/Reset/Biometric) | Done | Done | Done (5 screens, 5 widgets) | Yes | Production Ready |
| Accounts (CRUD + Transfer + Summary) | Done | Done | Done (3 screens, 3 widgets) | Yes | Production Ready |
| Categories (CRUD + AI Suggest) | Done | Done | Done (3 screens, 5 widgets) | Yes | Production Ready |
| Budgets (CRUD + Summary + Progress) | Done | Done | Done (3 screens, 4 widgets) | Yes | Production Ready |
| Transactions (CRUD + Stats + Voice + Receipt) | Done | Done | Done (3 screens, 6 widgets) | **NO** | Needs DI wiring |
| Dashboard | - | - | Partial (mock data hardcoded) | - | Needs real data |
| Settings/More | - | - | UI shell (theme toggle, logout) | - | Functional |

### 1.2 What's Partially Built (Model Only)

| Feature | Data Model | DataSource | Repository | Provider | Screens |
|---------|-----------|-----------|-----------|---------|---------|
| Goals | Done | Missing | Missing | Missing | Missing |
| Loans | Done | Missing | Missing | Missing | Missing |
| Investments | Done | Missing | Missing | Missing | Missing |

### 1.3 What's Completely Missing (from v2.0 Plan)

| Feature | Status | Plan Reference |
|---------|--------|---------------|
| Analytics & Reports (Charts) | Not started | Plan Phase 7 |
| AI Insights Engine | Not started | Plan Phase 11 |
| Family / Multi-User | Not started | Plan Phase 9 |
| Subscription & Billing (Razorpay) | Not started | Plan - Subscription endpoints |
| Notifications (In-app + Push) | Not started | Plan - Notification endpoints |
| Profile Screen | Not started | - |
| **Account Aggregator (Setu/Finvu)** | Not started | Plan Phase 8 |
| **SMS Transaction Parser** | Not started | Plan Phase 8 |
| **PDF/CSV Bank Statement Import** | Not started | Plan Phase 8 |
| **Email Statement Parser** | Not started | Plan Phase 8 |
| **Voice Entry (Speech-to-Text + NLP)** | UI widgets exist, no backend | Plan Phase 10 |
| **Receipt OCR (Camera + Extract)** | UI widget exists, no backend | Plan Phase 10 |
| **India-Specific (UPI, IFSC, Lakh/Crore)** | Not started | Plan Phase 8 |
| **Tax & Compliance (80C/80D/HRA/GST/TDS)** | Tax model in investments only | Plan Phase 6 |
| **PIN Lock & Auto-Lock** | Not started | Plan Phase 13 |
| **Device Management** | Not started | Plan Phase 13 |
| **Offline-First Sync** | Not started | Plan Phase 12 |
| **Localization (English + Hindi)** | Not started | Plan Phase 15 |

### 1.4 Critical Issues Found

| # | Issue | Severity | Impact |
|---|-------|----------|--------|
| 1 | **Transactions not registered in DI** | CRITICAL | Feature is built but non-functional |
| 2 | **Auth token not sent in API requests** | CRITICAL | All authenticated APIs return 400 |
| 3 | **Dashboard uses hardcoded mock data** | HIGH | No real financial data shown |
| 4 | **API response format mismatch** | HIGH | Fixed for auth; other endpoints may differ |
| 5 | **Refresh token in HttpOnly cookie** | MEDIUM | Dio may not handle cookies on Windows/desktop |
| 6 | **No error/empty/loading states** | MEDIUM | Bad UX when API fails or data is empty |
| 7 | **Indian number formatting missing** | MEDIUM | No Lakh/Crore format (shows 1,250,000 instead of 12,50,000) |
| 8 | **No offline capability** | LOW | App unusable without internet |

---

## 2. Implementation Phases

---

### PHASE 1: Stabilization & Core Fixes
**Priority:** CRITICAL | **Effort:** 2-3 days
**Goal:** Make all existing features work end-to-end with real API data

| # | Task | Details |
|---|------|---------|
| 1.1 | **Fix Auth Interceptor** | Ensure JWT Bearer token is attached to all authenticated requests. Debug 400 error on accounts API. |
| 1.2 | **Wire Transactions in DI** | Uncomment TransactionsRemoteDataSource + TransactionsRepositoryImpl in `injection.dart` |
| 1.3 | **Fix Token Refresh Flow** | Handle refresh token in HttpOnly cookie. Implement Dio cookie jar or coordinate with backend for token in body. |
| 1.4 | **Indian Number Formatting** | Create utility for Lakh/Crore format (`12,50,000` not `1,250,000`). Apply across all currency displays. |
| 1.5 | **Dashboard - Real Data** | Replace all mock data with API calls: accounts summary, transaction stats, recent transactions. Create `dashboard_provider.dart`. |
| 1.6 | **Error & Empty States** | Create shared widgets: `ErrorStateWidget`, `EmptyStateWidget`, `LoadingShimmer`. Apply to all screens. |
| 1.7 | **Clean Up Debug Logs** | Remove all temporary `debugPrint` statements from previous debugging session. |

**Deliverable:** All 6 existing features working with real API data. Indian formatting. Proper error handling.

**Files:** `api_interceptor.dart`, `api_client.dart`, `injection.dart`, `dashboard_screen.dart`, new `dashboard_provider.dart`, new `shared/widgets/error_state.dart`, new `shared/widgets/empty_state.dart`, new `shared/widgets/loading_shimmer.dart`, new `core/utils/currency_formatter.dart`

---

### PHASE 2: Goals Feature
**Priority:** HIGH | **Effort:** 2-3 days
**Goal:** Complete savings goals tracking with visual progress

| # | Task | Details |
|---|------|---------|
| 2.1 | Domain Layer | `GoalsRepository` interface |
| 2.2 | Data Source | API calls: CRUD + contributions + summary |
| 2.3 | Repository Impl | Wire datasource to domain |
| 2.4 | Provider | `GoalsState`, `GoalsNotifier` with Riverpod |
| 2.5 | Goals Screen | List with progress rings, summary card at top |
| 2.6 | Add/Edit Goal | Form: name, target amount, target date, icon, color |
| 2.7 | Goal Details | Circular progress visualization, contribution history, "Add Contribution" button |
| 2.8 | Widgets | `GoalCard`, `GoalProgressRing`, `ContributionTile`, `GoalSummaryCard` |
| 2.9 | Family Goals | Support `is_family_goal` flag for shared goals (Phase 9 integration) |
| 2.10 | DI + Routes | Register in injection.dart, replace placeholder route |

**API:** `GET/POST /goals`, `GET/PUT/DELETE /goals/:id`, `POST /goals/:id/contributions`, `GET /goals/summary`

---

### PHASE 3: Loans & EMI Tracking
**Priority:** HIGH | **Effort:** 2-3 days
**Goal:** India-specific loan management with EMI calculators

| # | Task | Details |
|---|------|---------|
| 3.1 | Domain Layer | `LoansRepository` interface |
| 3.2 | Data Source | API calls: CRUD + EMI payments + summary |
| 3.3 | Repository Impl | Wire datasource |
| 3.4 | Provider | `LoansState`, `LoansNotifier` |
| 3.5 | Loans Screen | List with summary card (total outstanding, total monthly EMI, next EMI due) |
| 3.6 | Add/Edit Loan | Form with **EMI calculator** (principal, rate, tenure -> auto-calculate EMI). Support India loan types: Home, Vehicle, Personal, Education, Gold, LAP, Credit Card EMI, Business |
| 3.7 | Loan Details | EMI schedule table, payment history, prepayment analysis, **80C principal tracking** (home loan), **80E interest tracking** (education loan) |
| 3.8 | EMI Calculator Widget | Standalone calculator: input principal/rate/tenure, show EMI + total interest + amortization |
| 3.9 | Widgets | `LoanCard`, `EmiScheduleTable`, `LoanSummaryCard`, `LoanTypePicker`, `EmiCalculator` |
| 3.10 | DI + Routes | Register and replace placeholder |

**API:** `GET/POST /loans`, `GET/PUT/DELETE /loans/:id`, `POST /loans/:id/emi-payment`, `GET /loans/summary`

**India-Specific:** 80C tracking for home loan principal, 24(b) for home loan interest, 80E for education loan interest

---

### PHASE 4: Investments & Tax Savings
**Priority:** HIGH | **Effort:** 3-4 days
**Goal:** Full portfolio tracking with Indian investment types and tax section tracking

| # | Task | Details |
|---|------|---------|
| 4.1 | Domain Layer | `InvestmentsRepository` interface |
| 4.2 | Data Source | API: CRUD + transactions + summary + tax + price sync |
| 4.3 | Repository Impl | Wire datasource |
| 4.4 | Provider | `InvestmentsState`, `InvestmentsNotifier` |
| 4.5 | **Portfolio Dashboard** | Total invested vs current value, P&L, **asset allocation pie chart** (fl_chart), returns % |
| 4.6 | **Holdings List** | Grouped by type: Mutual Funds, Stocks, FDs, PPF, EPF, NPS, Gold, SGB |
| 4.7 | Add Investment | **Type-specific forms**: MF (scheme code, folio, SIP amount), Stock (symbol, qty, avg price), FD (bank, rate, tenure, maturity), PPF/EPF (yearly contribution) |
| 4.8 | Investment Details | Value chart, buy/sell history, **XIRR calculation** for MF, dividend tracking for stocks |
| 4.9 | **Tax Savings Dashboard** | **80C summary** (PPF + ELSS + LIC + home loan principal + tuition = max 1.5L), **80D** (health insurance), **80E** (education loan interest), **80CCD** (NPS) |
| 4.10 | **Price Sync** | Integration with mfapi.in for MF NAV, stock API for NSE/BSE prices, gold rate API |
| 4.11 | **SIP Tracker** | Track SIP dates, amounts, auto-calculate via NAV |
| 4.12 | Widgets | `InvestmentCard`, `PortfolioPieChart`, `TaxSavingsCard`, `InvestmentTypePicker`, `HoldingsTile`, `SipTracker` |
| 4.13 | DI + Routes | Register and replace placeholder. Add `/investments/tax` route. |

**API:** All `/investments/*` endpoints + `/investments/tax/:year`

**India-Specific:** All Indian investment types (PPF, EPF, NPS, SSY, SGB, Post Office), 80C/80D/80E/80CCD tracking, XIRR returns

---

### PHASE 5: Analytics & Reports
**Priority:** HIGH | **Effort:** 3-4 days
**Goal:** Comprehensive financial analytics with charts (replaces bottom nav "Analytics" placeholder)

| # | Task | Details |
|---|------|---------|
| 5.1 | Provider | `AnalyticsState` with date range filters, period comparison |
| 5.2 | **Analytics Screen** | Tab views: Overview, Income, Expense, Trends, Comparison |
| 5.3 | **Income vs Expense Bar Chart** | Monthly comparison bar chart (fl_chart) |
| 5.4 | **Category Breakdown** | Donut chart with drill-down: tap category to see transactions |
| 5.5 | **Trend Line Chart** | Daily/weekly/monthly spending trend lines |
| 5.6 | **Cash Flow Chart** | Income vs outflow over time, predict month-end balance |
| 5.7 | Summary Cards | Average daily spend, highest category, savings rate, month-over-month change |
| 5.8 | **Date Range Picker** | Presets: This week, This month, Last 3/6/12 months, Custom range |
| 5.9 | **Net Worth Tracker** | Historical net worth chart (assets - liabilities over time) |
| 5.10 | **Export Reports** | PDF/CSV export of reports (optional for v1) |
| 5.11 | Update Routes | Replace placeholder analytics tab |

**Data Sources:** `GET /transactions/stats`, `GET /transactions/daily`, `GET /accounts/summary`, `GET /budgets/summary`

---

### PHASE 6: Profile & Security
**Priority:** HIGH | **Effort:** 2-3 days
**Goal:** User profile management + PIN lock + auto-lock + device management

| # | Task | Details |
|---|------|---------|
| **Profile** | | |
| 6.1 | Profile Screen | View: name, email, phone, avatar, plan, member since |
| 6.2 | Edit Profile | Form with validation, photo upload (MinIO) |
| 6.3 | Change Password | Current + new password with strength indicator |
| 6.4 | Preferences | Currency selector, locale, date format (DD-MM-YYYY), notification prefs |
| **PIN Lock** | | |
| 6.5 | Set PIN Screen | 4-6 digit PIN creation with confirmation |
| 6.6 | PIN Entry Screen | Unlock with PIN on app launch (if biometric disabled) |
| 6.7 | Change/Remove PIN | Settings option to update or disable PIN |
| 6.8 | Failed Attempts | Lock account after 5 failed attempts (30 min cooldown) |
| **Auto-Lock** | | |
| 6.9 | Activity Tracking | Track last user interaction timestamp |
| 6.10 | Auto-Lock Timer | Configurable: 1, 5, 15, 30 mins of inactivity |
| 6.11 | Lock Screen Overlay | Show lock screen when app returns from background |
| **Device Management** | | |
| 6.12 | Devices List | Show registered devices with last active time |
| 6.13 | Remove Device | Revoke access from specific device |
| 6.14 | Update Routes | Wire all profile/security routes |

**API:** `GET /auth/me`, `PUT /auth/me`, `GET /auth/devices`, `DELETE /auth/devices/:id`

---

### PHASE 7: Notifications
**Priority:** MEDIUM | **Effort:** 2-3 days
**Goal:** In-app notification center + push notifications (FCM)

| # | Task | Details |
|---|------|---------|
| 7.1 | Data Model | `NotificationModel` (id, type, title, body, isRead, actionType, actionData, createdAt) |
| 7.2 | Full stack | Domain + DataSource + Repository + Provider |
| 7.3 | Notifications Screen | List with read/unread visual distinction, swipe to dismiss, "Mark all read" |
| 7.4 | Notification Types | Budget alerts, EMI reminders, goal milestones, family activity, system messages |
| 7.5 | Badge | Unread count badge on bell icon (dashboard) and bottom nav |
| 7.6 | **FCM Setup** | Firebase Cloud Messaging integration. Register push token. Handle foreground/background notifications. |
| 7.7 | **Local Notifications** | Schedule local reminders: EMI due dates, budget limits, SIP dates |
| 7.8 | DI + Routes | Register and wire |

**API:** All `/notifications/*` endpoints

---

### PHASE 8: Bank Integration & Smart Import
**Priority:** MEDIUM | **Effort:** 4-5 days
**Goal:** Auto-fetch bank data + manual import via PDF/CSV + SMS parsing

This is a major India-specific feature set. Broken into sub-phases:

#### 8A: PDF Bank Statement Import (2 days)
| # | Task | Details |
|---|------|---------|
| 8A.1 | **PDF Upload UI** | File picker for PDF bank statements |
| 8A.2 | **Backend PDF Parser** | API endpoint to upload PDF, backend extracts transactions (supports HDFC, ICICI, SBI, Axis, Kotak, Yes Bank, IDFC, and other major banks) |
| 8A.3 | **Preview & Confirm** | Show extracted transactions, let user review, auto-categorize, confirm to import |
| 8A.4 | **CSV Import** | Alternative CSV upload with column mapping |
| 8A.5 | **Import History** | Track imported statements to avoid duplicates |

**API:** `POST /import/pdf` (upload), `POST /import/csv`, `GET /import/history`

**Backend Needed:** PDF parsing service per bank format. This is primarily backend work - frontend just uploads and displays results.

#### 8B: SMS Transaction Parser (2 days)
| # | Task | Details |
|---|------|---------|
| 8B.1 | **SMS Permission** | Request SMS read permission (Android only) |
| 8B.2 | **SMS Reader Service** | Read bank transaction SMS from inbox |
| 8B.3 | **SMS Parser** | Parse Indian bank SMS formats: credited/debited, UPI, NEFT/RTGS/IMPS. Support: SBI, HDFC, ICICI, Axis, Kotak, BOB, PNB, etc. |
| 8B.4 | **Auto-Categorize** | Map merchant names to categories (Swiggy->Food, Amazon->Shopping) |
| 8B.5 | **Bulk Import UI** | Show parsed SMS list, select/deselect, confirm import |
| 8B.6 | **Background Listener** | Optional: listen for new SMS and auto-suggest transaction entry |

**Note:** This is Android-only (iOS doesn't allow SMS access). On iOS, use PDF/manual entry instead.

#### 8C: Account Aggregator (1-2 days)
| # | Task | Details |
|---|------|---------|
| 8C.1 | **AA Consent Flow** | Integrate Setu/Finvu Account Aggregator SDK |
| 8C.2 | **Consent UI** | Show consent screen, bank selection, approve sharing |
| 8C.3 | **Data Fetch** | Fetch account statements via AA API |
| 8C.4 | **Auto-Import** | Parse AA data into transactions with auto-categorization |

**API:** `POST /aa/consent`, `GET /aa/status`, `POST /aa/fetch-data`

**Note:** Account Aggregator requires RBI-licensed FIP. Backend needs Setu/Finvu integration. This is backend-heavy.

#### 8D: India-Specific Utilities (1 day)
| # | Task | Details |
|---|------|---------|
| 8D.1 | **IFSC Lookup** | Search IFSC code, get bank/branch details. Used in account creation. |
| 8D.2 | **UPI ID Validation** | Validate UPI ID format (user@bank) |
| 8D.3 | **NEFT/RTGS/IMPS Tags** | Auto-tag transfer type based on amount/description |
| 8D.4 | **Indian Payment Methods** | UPI (GPay, PhonePe, Paytm, BHIM), NEFT, RTGS, IMPS, cheque in transaction form |
| 8D.5 | **DD-MM-YYYY Format** | Date display in Indian format throughout app |

**API:** `GET /ifsc/:code`, `GET /upi/parse`

---

### PHASE 9: Voice Entry & Receipt OCR
**Priority:** MEDIUM | **Effort:** 3-4 days
**Goal:** Add expenses by voice, scan receipts to auto-extract data

**Note:** UI widgets already exist in the transactions feature (`voice_input_sheet.dart`, `receipt_scanner_sheet.dart`, `voice_input_provider.dart`). This phase is about connecting them to real backend services.

#### 9A: Voice Entry (2 days)
| # | Task | Details |
|---|------|---------|
| 9A.1 | **Speech-to-Text** | Integrate `speech_to_text` Flutter package for on-device STT |
| 9A.2 | **Backend NLP** | Send transcript to `POST /voice/parse` for entity extraction (amount, category, merchant, type) |
| 9A.3 | **Indian Context NLP** | Handle: "500 rupees", "2 lakh", "paanch sau", amount in Hindi words |
| 9A.4 | **Confirmation UI** | Show parsed transaction preview, edit before save |
| 9A.5 | **Voice Commands** | Support: "Add 500 for groceries", "Received 50000 salary", "Transfer 10000 from HDFC to SBI" |
| 9A.6 | **Offline Queue** | Queue voice entries when offline, process when connected |
| 9A.7 | **Multi-language** | English + Hindi voice recognition |

**API:** `POST /voice/transcribe`, `POST /voice/parse`, `POST /voice/transcribe-and-parse`

#### 9B: Receipt OCR (2 days)
| # | Task | Details |
|---|------|---------|
| 9B.1 | **Camera Capture** | Full-screen camera with receipt edge detection |
| 9B.2 | **Image Processing** | Crop, rotate, enhance contrast before OCR |
| 9B.3 | **Backend OCR** | Upload image to `POST /receipts/scan`, backend processes with Tesseract/Google Vision |
| 9B.4 | **Data Extraction** | Extract: merchant name, date, total amount, GST number, payment method, line items |
| 9B.5 | **Auto-Fill Form** | Pre-fill add transaction form with extracted data |
| 9B.6 | **Auto-Categorize** | Map merchant to category (Big Bazaar -> Shopping) |
| 9B.7 | **Receipt Storage** | Attach receipt image to transaction for future reference |
| 9B.8 | **GST Extraction** | Pull GSTIN from receipt for business users |
| 9B.9 | **Supported Receipts** | Retail bills, restaurant bills, fuel receipts, e-commerce screenshots, utility bills, medical bills |

**API:** `POST /receipts/scan`, `POST /receipts/parse`, `GET /receipts/:id`

---

### PHASE 10: AI Insights Engine
**Priority:** MEDIUM | **Effort:** 2-3 days
**Goal:** Personalized financial recommendations and spending analysis

| # | Task | Details |
|---|------|---------|
| 10.1 | Data Model | `InsightModel` (type, category, title, description, priority, actionType, actionData, validUntil) |
| 10.2 | Full Stack | Domain + DataSource + Repository + Provider |
| 10.3 | **Insights Dashboard Widget** | Top 3 insights carousel on home dashboard |
| 10.4 | **Insights Screen** | Full list: filters by type (spending, savings, anomaly, forecast) |
| 10.5 | **Insight Card** | Dismissible, with action button (e.g., "View Transactions", "Set Budget") |
| 10.6 | **Insight Types** | |
| | Spending Patterns | "You spend 40% more on weekends" |
| | Savings Opportunities | "Switch to annual Spotify, save 600" |
| | Bill Predictions | "Your electricity bill is usually 2,500" |
| | Anomaly Detection | "Unusual 15,000 spend at electronics" |
| | Budget Recommendations | "Based on income, allocate 8,000 for food" |
| | Goal Achievability | "At current rate, you'll reach goal in 8 months" |
| | Loan Insights | "Prepay 50,000 to save 32,000 interest" |
| | Category Trends | "Food spending up 25% vs last month" |
| | Merchant Analysis | "You visit Swiggy 12 times/month" |
| | Cash Flow Forecast | "You might be short 5,000 by month end" |
| 10.7 | **Trigger Generation** | Button to request new analysis from backend |
| 10.8 | DI + Routes | Register and wire |

**API:** `GET /insights`, `GET /insights/dashboard`, `POST /insights/generate`, `POST /insights/:id/read`, `POST /insights/:id/dismiss`

**Backend Needed:** Rule-based engine + optional OpenAI/Gemini for advanced natural language insights.

---

### PHASE 11: Family / Multi-User
**Priority:** MEDIUM | **Effort:** 3-4 days
**Goal:** Family sharing with shared budgets, goals, expense splitting

| # | Task | Details |
|---|------|---------|
| 11.1 | Data Models | `FamilyModel`, `FamilyMember`, `FamilyInvite`, `FamilyActivity` |
| 11.2 | Full Stack | Domain + DataSource + Repository + Provider |
| 11.3 | **Create Family** | Name, generate invite code/link |
| 11.4 | **Invite Members** | Email invite, share invite code, pending invites list |
| 11.5 | **Join Family** | Enter invite code, accept invite from deep link |
| 11.6 | **Family Screen** | Member list with roles (OWNER/ADMIN/MEMBER/VIEWER), settings |
| 11.7 | **Role Management** | Change member roles, permissions (view transactions, edit budgets, invite others) |
| 11.8 | **Shared Accounts** | Mark accounts as family-shared vs personal (private) |
| 11.9 | **Family Budgets** | Combined household budget tracking |
| 11.10 | **Family Goals** | Save together (vacation, house, etc.) |
| 11.11 | **Family Dashboard** | Combined family balance, member-wise spending, total family stats |
| 11.12 | **Activity Feed** | "Dad added 5000 expense", "Mom contributed to vacation goal" |
| 11.13 | **Expense Splitting** | Split bills among family members |
| 11.14 | **Allowance Tracking** | Track kids' pocket money |
| 11.15 | **Privacy Controls** | Hide personal accounts, control transaction visibility, "hidden mode" |
| 11.16 | DI + Routes | Register and wire |

**API:** All `/family/*` endpoints

---

### PHASE 12: Subscription & Payments
**Priority:** MEDIUM-LOW | **Effort:** 3-4 days
**Goal:** Razorpay/UPI payment integration, plan limits enforcement

| # | Task | Details |
|---|------|---------|
| 12.1 | Data Models | `SubscriptionPlan`, `Subscription`, `Invoice`, `UsageLimits` |
| 12.2 | Full Stack | Domain + DataSource + Repository + Provider |
| 12.3 | **Plans Screen** | Comparison: Free (3 accounts, 50 txn/mo, 1 user) vs Pro (unlimited + AI + bank sync) vs Premium (everything + priority support + API) |
| 12.4 | **Razorpay Integration** | Payment gateway for card/UPI/netbanking checkout |
| 12.5 | **UPI Payment** | Direct UPI payment with UTR verification |
| 12.6 | **Invoice History** | Past invoices with PDF download |
| 12.7 | **Usage Dashboard** | Current usage vs plan limits (accounts, transactions, family members) |
| 12.8 | **Paywall Logic** | Soft paywall: show "Upgrade to Pro" when hitting limits. Block actions gracefully. |
| 12.9 | **Upgrade/Downgrade** | Plan change flow with prorated billing |
| 12.10 | DI + Routes | Register and wire |

**API:** All `/subscriptions/*` endpoints

---

### PHASE 13: Tax & Compliance (India-Specific)
**Priority:** MEDIUM-LOW | **Effort:** 2-3 days
**Goal:** Comprehensive India tax tracking and report generation

| # | Task | Details |
|---|------|---------|
| 13.1 | **80C Tracker** | PPF contributions + ELSS investments + LIC premiums + Home loan principal + Children tuition fees + Sukanya Samriddhi. Show 1.5L limit utilization. |
| 13.2 | **80D Tracker** | Health insurance premiums (self + parents). Show 25K/50K limit. |
| 13.3 | **80E Tracker** | Education loan interest deduction (no limit) |
| 13.4 | **80CCD Tracker** | NPS contributions (additional 50K under 80CCD(1B)) |
| 13.5 | **24(b) Tracker** | Home loan interest (2L limit for self-occupied) |
| 13.6 | **HRA Calculator** | Input: basic salary, HRA received, rent paid, city type. Calculate exemption. |
| 13.7 | **GST Tracker** | For business users: track GST input credit on expenses |
| 13.8 | **TDS Tracker** | Track TDS deducted on salary, FD interest, professional fees |
| 13.9 | **Tax Summary Screen** | Annual dashboard: section-wise deductions, total tax saved, investment suggestions |
| 13.10 | **Tax Report Generator** | Downloadable PDF: section-wise breakdown ready for ITR filing |

**API:** `GET /tax/80c-summary`, `GET /tax/report/:year`, `GET /investments/tax/:year`

**Data Sources:** Pulls from: investments (80C, 80D, 80CCD), loans (80E, 24b), transactions (rent for HRA, insurance premiums)

---

### PHASE 14: Offline-First & Data Sync
**Priority:** LOW | **Effort:** 4-5 days
**Goal:** Full offline capability with conflict resolution

| # | Task | Details |
|---|------|---------|
| 14.1 | **Hive Adapters** | Type adapters for all models (Transaction, Account, Category, Budget, Goal, Loan, Investment) |
| 14.2 | **Local Cache Layer** | Write-through cache in each repository: save to Hive on every API response |
| 14.3 | **Offline Mutations Queue** | Queue create/update/delete operations when offline |
| 14.4 | **Sync Service** | Push local changes on reconnect via `POST /sync/push` |
| 14.5 | **Pull Changes** | Fetch server changes since last sync via `POST /sync/pull` |
| 14.6 | **Conflict Resolution** | When same record modified locally and on server: show conflict UI, let user pick |
| 14.7 | **Connectivity Listener** | Auto-detect online/offline, trigger sync on reconnect |
| 14.8 | **Sync Status Indicator** | Show sync status in app bar: synced, syncing, offline, conflict |
| 14.9 | **Optimistic Updates** | Show local changes immediately, sync in background |

**API:** `POST /sync/push`, `POST /sync/pull`, `GET /sync/status`, `POST /sync/conflicts/:id/resolve`

---

### PHASE 15: Polish & Production Readiness
**Priority:** LOW | **Effort:** 3-5 days
**Goal:** App store ready

| # | Task | Details |
|---|------|---------|
| 15.1 | **Localization** | English + Hindi using Flutter `intl`. All strings externalized. |
| 15.2 | **Security Hardening** | Certificate pinning (Dio), secure screen flag (prevent screenshots on sensitive screens), session timeout |
| 15.3 | **Performance** | Lazy loading for lists, image caching, widget optimization, startup profiling |
| 15.4 | **Animations** | Lottie for splash, page transitions, hero animations, micro-interactions on add/delete |
| 15.5 | **Deep Linking** | Handle: family invite links, password reset links, notification taps |
| 15.6 | **App Icons & Splash** | Proper icons (all sizes), native splash screen |
| 15.7 | **Error Tracking** | Firebase Crashlytics for production crash reports |
| 15.8 | **User Analytics** | Firebase Analytics for feature usage tracking (optional, privacy-first) |
| 15.9 | **Testing** | Unit tests for providers, integration tests for key flows (login, add transaction, add goal) |
| 15.10 | **CI/CD** | GitHub Actions: lint, test, build APK/IPA/Windows |
| 15.11 | **App Store** | Screenshots, descriptions, privacy policy, terms |
| 15.12 | **Widget Support** | Android home screen widget (quick balance view) - stretch goal |

---

## 3. Phase Priority & Timeline

| Phase | Feature | Priority | Est. Days | Cumulative |
|-------|---------|----------|-----------|------------|
| **1** | Stabilization & Core Fixes | CRITICAL | 2-3 | 2-3 |
| **2** | Goals | HIGH | 2-3 | 4-6 |
| **3** | Loans & EMI | HIGH | 2-3 | 6-9 |
| **4** | Investments & Tax Savings | HIGH | 3-4 | 9-13 |
| **5** | Analytics & Reports | HIGH | 3-4 | 12-17 |
| **6** | Profile & Security (PIN/Auto-Lock) | HIGH | 2-3 | 14-20 |
| **7** | Notifications (In-app + FCM) | MEDIUM | 2-3 | 16-23 |
| **8** | Bank Integration & Smart Import | MEDIUM | 4-5 | 20-28 |
| **9** | Voice Entry & Receipt OCR | MEDIUM | 3-4 | 23-32 |
| **10** | AI Insights Engine | MEDIUM | 2-3 | 25-35 |
| **11** | Family / Multi-User | MEDIUM | 3-4 | 28-39 |
| **12** | Subscription & Payments | MEDIUM-LOW | 3-4 | 31-43 |
| **13** | Tax & Compliance | MEDIUM-LOW | 2-3 | 33-46 |
| **14** | Offline Sync | LOW | 4-5 | 37-51 |
| **15** | Polish & Production | LOW | 3-5 | 40-56 |

**Total: ~40-56 development days**

---

## 4. Backend Dependencies & Coordination

Some phases require backend API work that may not exist yet:

| Phase | Backend Needed | Status |
|-------|---------------|--------|
| Phase 1 | Fix token handling, verify all existing endpoints | Likely exists, needs testing |
| Phase 2-5 | Goals, Loans, Investments, Analytics endpoints | Check if APIs are live |
| Phase 8A | PDF bank statement parser (per-bank format) | **Major backend work** |
| Phase 8B | SMS parser patterns for Indian banks | Can be client-side |
| Phase 8C | Setu/Finvu Account Aggregator integration | **Requires AA license + backend** |
| Phase 9A | Voice NLP parsing (`/voice/parse`) | Backend AI service |
| Phase 9B | Receipt OCR engine (`/receipts/scan`) | Backend Tesseract/Vision |
| Phase 10 | Insights generation engine | Backend rule engine + AI |
| Phase 13 | Tax calculation endpoints | Backend logic |

**Recommendation:** Before starting each phase, verify the backend APIs are available and test with Postman/curl. This prevents frontend work on non-existent endpoints.

---

## 5. My Recommendations

### Architecture Improvements
1. **Create `BaseState` class** - Consistent loading/error/data pattern across all features. Reduces boilerplate significantly.
2. **Create `BaseRepository`** - Common error handling, caching, retry logic in one place.
3. **Currency Service** - Centralized service for Indian formatting (Lakh/Crore), currency symbols, amount-in-paise conversion.
4. **Feature Flag System** - Toggle features based on subscription plan (Free/Pro/Premium) without code changes.

### UX Recommendations
1. **Skeleton Loading** - Use shimmer loading instead of spinners for better perceived performance.
2. **Haptic Feedback** - Light haptic on button taps, success/error haptics.
3. **Pull-to-Refresh** - On all list screens.
4. **Swipe Actions** - Swipe left to delete, right to edit on list items.
5. **Smart Defaults** - Pre-select most-used category, auto-detect expense/income, remember last account used.
6. **Quick Add Widget** - Floating button for instant expense entry (amount + category, that's it).

### India-Specific Quick Wins
1. **Lakh/Crore formatting** - Do this in Phase 1, it affects every screen.
2. **Indian categories** - Kirana, Domestic Help, Society Maintenance, Festival Expenses, etc.
3. **UPI as default payment method** - In transaction form, UPI should be first option.
4. **DD-MM-YYYY date format** - Throughout the app.

### What I'd Prioritize Differently from the Plan
1. **Phase 8 (Bank Integration)** is high-value but **extremely backend-dependent**. I'd move SMS parsing earlier (it's client-side) and defer Account Aggregator to later.
2. **Phase 13 (Tax)** could be partially done in Phase 4 (Investments) since they're closely related. Tax summary screen = investment tax tracking + loan interest tracking.
3. **Phase 6 (Security)** should be HIGH priority - PIN lock and auto-lock are expected by Indian finance app users.

---

## 6. Approval

**Please review and approve this plan.** Once approved, I will begin with **Phase 1 (Stabilization & Core Fixes)** immediately.

**Options:**
- **Approve as-is** - Start Phase 1
- **Reorder phases** - Tell me your preferred order
- **Skip/defer features** - Mark specific phases as "later"
- **Add requirements** - Anything I missed?
- **Adjust priorities** - Change what's HIGH vs MEDIUM vs LOW

---

*Document generated: February 12, 2026*
*Project: Spendex (FinTrace) Flutter App v2.0*
*Backend API: https://api.spendex.in/api/v1*
*Reference: .same/plan (FinTrace Master Plan)*
