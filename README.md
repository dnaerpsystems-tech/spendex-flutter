# Spendex Flutter App

## Project Overview

**Spendex** is a comprehensive personal finance management mobile application built with Flutter. It's a multi-tenant SaaS platform that helps users track expenses, manage budgets, monitor investments, and achieve financial goals.

---

## Technical Stack

### Frontend
- **Framework:** Flutter 3.x (latest stable)
- **State Management:** Riverpod 2.x
- **Dependency Injection:** GetIt + Injectable
- **Local Database:** Hive (for offline-first capability)
- **HTTP Client:** Dio with interceptors
- **Navigation:** Go Router
- **Charts:** FL Chart
- **Animations:** Lottie, built-in animations
- **Form Validation:** Formz
- **Secure Storage:** flutter_secure_storage

### Backend API
- **Base URL:** `https://api.spendex.in/api/v1`
- **Authentication:** JWT Bearer tokens (access + refresh tokens)
- **Currency:** INR (amounts in paise - 100 paise = ₹1)
- **Date Format:** ISO 8601

---

## Authentication System

### Authentication Flow
1. **Registration** → OTP Verification → Profile Setup → Dashboard
2. **Login** → JWT Tokens → Dashboard (or 2FA if enabled)
3. **Token Refresh** → Automatic via interceptor when access token expires
4. **Biometric Login** → WebAuthn/Fingerprint/Face ID support

### API Endpoints

```
POST /auth/register
Body: { email, password, name, phone? }
Response: { user, requiresOTP: true }

POST /auth/login
Body: { email, password }
Response: { accessToken, refreshToken, expiresIn, user }

POST /auth/refresh
Body: { refreshToken }
Response: { accessToken, refreshToken, expiresIn }

POST /auth/send-otp
Body: { email, purpose: "verification" | "password_reset" }

POST /auth/verify-otp
Body: { email, otp }
Response: { verified, accessToken, refreshToken }

POST /auth/forgot-password
Body: { email }

POST /auth/reset-password
Body: { token, password }

GET /auth/me (Auth Required)
Response: { user with tenant and subscription }

POST /auth/logout (Auth Required)
```

### Token Storage
- Store tokens securely using `flutter_secure_storage`
- Access token expires in 15 minutes
- Refresh token expires in 7 days
- Implement automatic token refresh via Dio interceptor

### Biometric Authentication
```
GET /auth/biometric/register-options (Auth Required)
POST /auth/biometric/register (Auth Required)
GET /auth/biometric/login-options
POST /auth/biometric/login
GET /auth/biometric/credentials (Auth Required)
DELETE /auth/biometric/credentials/:id (Auth Required)
```

---

## Core Features

### 1. Dashboard (Home Screen)
- **Net Worth Card:** Total assets - liabilities
- **Monthly Summary:** Income vs Expenses with savings rate
- **Quick Actions:** Add transaction, transfer, scan receipt
- **Recent Transactions:** Last 5-10 transactions
- **Budget Alerts:** Over-budget warnings
- **AI Insights Widget:** Top 3 financial insights
- **Account Balances:** Scrollable account cards

### 2. Accounts Management
```
GET /accounts - List all accounts
GET /accounts/summary - Total balance, assets, liabilities
GET /accounts/:id - Account details with transactions
POST /accounts - Create account
PUT /accounts/:id - Update account
DELETE /accounts/:id - Delete account
POST /accounts/transfer - Transfer between accounts
```

**Account Types:** SAVINGS, CURRENT, CREDIT_CARD, CASH, WALLET, INVESTMENT, LOAN, OTHER

### 3. Transactions
```
GET /transactions - List with filters & pagination
GET /transactions/stats - Income/expense statistics
GET /transactions/daily - Daily totals for charts
GET /transactions/:id - Transaction details
POST /transactions - Create transaction
PUT /transactions/:id - Update transaction
DELETE /transactions/:id - Delete transaction
```

**Transaction Types:** INCOME, EXPENSE, TRANSFER

### 4. Categories
```
GET /categories - All categories (grouped by type)
GET /categories/income - Income categories only
GET /categories/expense - Expense categories only
POST /categories - Create custom category
POST /categories/suggest - AI category suggestion
PUT /categories/:id - Update category
DELETE /categories/:id - Delete custom category
```

### 5. Budgets
```
GET /budgets - List budgets with progress
GET /budgets/summary - Total budget stats
GET /budgets/:id - Budget with transactions
POST /budgets - Create budget
PUT /budgets/:id - Update budget
DELETE /budgets/:id - Delete budget
```

**Budget Periods:** WEEKLY, MONTHLY, QUARTERLY, YEARLY

### 6. Savings Goals
```
GET /goals - List all goals
GET /goals/summary - Goals overview
GET /goals/:id - Goal with contributions
POST /goals - Create goal
PUT /goals/:id - Update goal
POST /goals/:id/contributions - Add contribution
DELETE /goals/:id - Delete goal
```

### 7. Loans & EMI Tracking
```
GET /loans - List loans with status
GET /loans/summary - Total outstanding, monthly EMI
GET /loans/:id - Loan with EMI schedule
POST /loans - Create loan (auto-generates EMI schedule)
PUT /loans/:id - Update loan
POST /loans/:id/emi-payment - Record EMI payment
DELETE /loans/:id - Delete loan
```

**Loan Types:** HOME, VEHICLE, PERSONAL, EDUCATION, GOLD, BUSINESS, OTHER

### 8. Investment Portfolio
```
GET /investments - List investments
GET /investments/summary - Portfolio summary with returns
GET /investments/tax/:year - Tax savings by section
GET /investments/:id - Investment details
POST /investments - Add investment
PUT /investments/:id - Update investment
DELETE /investments/:id - Delete investment
POST /investments/sync-prices - Sync latest prices
```

**Investment Types:** mutual_fund, stock, fixed_deposit, recurring_deposit, ppf, epf, nps, gold, real_estate, sukanya_samriddhi, sovereign_gold_bond, post_office, crypto, other

**Tax Sections:** 80C, 80CCC, 80CCD, 80D, 80E, 80G, 80TTA, 80TTB, none

### 9. Subscription & Billing
```
GET /subscriptions/plans - Available plans (public)
GET /subscriptions/current - Current subscription
GET /subscriptions/usage - Usage vs limits
POST /subscriptions/checkout - Create Razorpay order
POST /subscriptions/verify-payment - Verify payment
POST /subscriptions/upgrade - Upgrade plan
POST /subscriptions/downgrade - Downgrade plan
POST /subscriptions/cancel - Cancel subscription
POST /subscriptions/resume - Resume subscription
GET /subscriptions/invoices - Invoice history
GET /subscriptions/invoices/:id/download - Download PDF
POST /subscriptions/upi/create - UPI payment
POST /subscriptions/upi/verify - Verify UPI with UTR
```

**Subscription Tiers:**
1. **Free:** 3 accounts, 50 transactions/month, 1 user
2. **Pro:** Unlimited accounts, unlimited transactions, 5 family members, AI insights, bank sync
3. **Premium:** Everything + priority support, API access

### 10. Family/Multi-User
```
GET /family - Family details with members
POST /family/invite - Send invite
POST /family/invites/:token/accept - Accept invite
DELETE /family/invites/:id - Cancel invite
PUT /family/members/:id - Update member role
DELETE /family/members/:id - Remove member
POST /family/leave - Leave family
POST /family/transfer-ownership - Transfer ownership
```

**User Roles:** OWNER, ADMIN, MEMBER, VIEWER

### 11. AI Insights
```
GET /insights - Get all insights
GET /insights/dashboard - Top insights for home
POST /insights/generate - Trigger new analysis
POST /insights/:id/read - Mark as read
POST /insights/:id/dismiss - Dismiss insight
```

### 12. Voice Entry & Receipt Scanning
```
POST /voice/transcribe - Audio to text
POST /voice/parse - Text to transaction
POST /voice/transcribe-and-parse - Combined
POST /receipts/scan - OCR receipt scanning
POST /receipts/parse - Extract transaction data
```

### 13. Data Sync (Offline-First)
```
POST /sync/push - Push local changes
POST /sync/pull - Pull server changes
GET /sync/status - Sync status
POST /sync/conflicts/:id/resolve - Resolve conflicts
```

### 14. Notifications
```
GET /notifications - List notifications
GET /notifications/unread-count - Unread count
PUT /notifications/:id/read - Mark as read
PUT /notifications/read-all - Mark all read
DELETE /notifications/:id - Delete notification
POST /notifications/register-push - Register FCM token
```

---

## UI/UX Design Guidelines

### Design System
- **Theme:** Support light and dark mode
- **Colors:**
  - Primary: Emerald/Teal (#10B981)
  - Income: Green (#22C55E)
  - Expense: Red (#EF4444)
  - Transfer: Blue (#3B82F6)
- **Typography:** Google Fonts - Poppins
- **Spacing:** 8px base unit
- **Border Radius:** 12-16px for cards

### Key Screens
1. Splash Screen - Logo animation
2. Onboarding - 3-4 feature highlights
3. Login/Register - Clean form
4. OTP Verification - 6-digit input with timer
5. Dashboard - Scrollable with widgets
6. Accounts List - Card-based layout
7. Account Details - Balance + transaction list
8. Add Transaction - Bottom sheet or full screen
9. Transaction List - Grouped by date
10. Categories - Grid with icons
11. Budgets - Progress cards
12. Goals - Visual progress rings
13. Loans - EMI schedule table
14. Investments - Portfolio pie chart
15. Insights - Card carousel
16. Profile - Settings and preferences
17. Subscription - Plan comparison
18. Family - Member list with roles

### Navigation
- **Bottom Navigation:** Home, Transactions, Add (+), Analytics, More
- **Floating Action Button:** Quick add transaction

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── api_interceptor.dart
│   │   └── endpoints.dart
│   ├── storage/
│   └── utils/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── accounts/
│   ├── transactions/
│   ├── categories/
│   ├── budgets/
│   ├── goals/
│   ├── loans/
│   ├── investments/
│   ├── insights/
│   ├── family/
│   ├── subscription/
│   ├── notifications/
│   ├── settings/
│   └── sync/
├── shared/
│   ├── widgets/
│   ├── extensions/
│   └── mixins/
└── l10n/
```

---

## Security Requirements

1. Biometric Lock: Fingerprint/Face ID
2. PIN Lock: 4-6 digit PIN option
3. Session Timeout: Auto-logout after inactivity
4. Secure Storage: All sensitive data encrypted
5. Certificate Pinning: Prevent MITM attacks

---

## Success Criteria

- [ ] All API endpoints integrated
- [ ] Offline-first with sync
- [ ] Biometric authentication working
- [ ] Razorpay payments functional
- [ ] Push notifications configured
- [ ] Dark/Light theme support
- [ ] Responsive on all screen sizes
- [ ] Smooth 60fps animations
- [ ] App size < 30MB
- [ ] Startup time < 2 seconds

---

## Resources

- **API Documentation:** https://same-1mnpyze0jpj-latest.netlify.app
- **API Health Check:** https://api.spendex.in/health
- **Design Inspiration:** Cred, Jupiter, Fi Money
