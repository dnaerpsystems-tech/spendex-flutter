# Email Parser - Screen Flow Diagram

## 🗺️ Navigation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         App Home Screen                          │
│                   (Bank Import Home Screen)                      │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ Tap "Email Parser"
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Email Parser Screen                          │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    No Accounts State                      │  │
│  │  • Large icon with description                            │  │
│  │  • "Connect Email Account" button                         │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────┬────────────────────────────────────┬───────────────┘
             │                                    │
             │ Tap "Connect Email Account"        │ Already has accounts
             ▼                                    ▼
┌──────────────────────────┐     ┌─────────────────────────────────┐
│  Email Setup Screen      │     │   Email Parser Screen           │
│  • Email field           │     │   (With Accounts)               │
│  • Password field        │     │  ┌───────────────────────────┐  │
│  • Provider dropdown     │     │  │ Connected Accounts Section│  │
│  • Advanced settings     │     │  │ • EmailAccountCard list   │  │
│  • Connect button        │     │  │ • Add button              │  │
│                          │     │  └───────────────────────────┘  │
│  [Help Section]          │     │  ┌───────────────────────────┐  │
│  • Gmail instructions    │     │  │ Active Filters (chips)    │  │
│  • Outlook instructions  │     │  └───────────────────────────┘  │
└──────────┬───────────────┘     │  ┌───────────────────────────┐  │
           │                     │  │ Statistics Row            │  │
           │ Success             │  │ Total|Parsed|Failed|Sel   │  │
           └────────────────────►│  └───────────────────────────┘  │
                                 │  ┌───────────────────────────┐  │
                                 │  │ Email List                │  │
                                 │  │ • EmailMessageCard items  │  │
                                 │  │ • Pull-to-refresh         │  │
                                 │  └───────────────────────────┘  │
                                 │                                 │
                                 │  [FAB: Context-aware]           │
                                 │  • Fetch Emails                 │
                                 │  • Parse Emails                 │
                                 │  • Import Selected              │
                                 └──┬──────────┬──────────┬────────┘
                                    │          │          │
                ┌───────────────────┘          │          └──────────────┐
                │                              │                         │
                │ Tap Filter                   │ Tap Email Card          │ Tap Import
                ▼                              ▼                         ▼
┌──────────────────────────┐   ┌──────────────────────────┐   ┌────────────────┐
│ Email Filters Sheet      │   │ Email Details Screen     │   │  Confirmation  │
│ (Modal Bottom Sheet)     │   │  ┌────────────────────┐  │   │     Dialog     │
│  ┌────────────────────┐  │   │  │ Email Header Card  │  │   │                │
│  │ Banks (FilterChip) │  │   │  │ • Subject          │  │   │ Import N txns? │
│  │ HDFC, ICICI, SBI.. │  │   │  │ • From, Date       │  │   │                │
│  └────────────────────┘  │   │  │ • Type, Bank       │  │   │ [Cancel][OK]   │
│  ┌────────────────────┐  │   │  └────────────────────┘  │   └────┬───────────┘
│  │ Date Range         │  │   │  ┌────────────────────┐  │        │
│  │ [Calendar picker]  │  │   │  │ Parsed Transaction │  │        │ Confirm
│  └────────────────────┘  │   │  │ (if available)     │  │        │
│  ┌────────────────────┐  │   │  └────────────────────┘  │        ▼
│  │ Email Types        │  │   │  ┌────────────────────┐  │   ┌────────────────┐
│  │ ☑ Notifications    │  │   │  │ Email Content      │  │   │  Importing...  │
│  │ ☑ Statements       │  │   │  │ (Selectable text)  │  │   │                │
│  │ ☑ Receipts         │  │   │  └────────────────────┘  │   │  [Progress]    │
│  └────────────────────┘  │   │  ┌────────────────────┐  │   └────┬───────────┘
│  ┌────────────────────┐  │   │  │ Attachments List   │  │        │
│  │ Include Attachments│  │   │  │ (if available)     │  │        │ Success
│  │ [Toggle]           │  │   │  └────────────────────┘  │        │
│  └────────────────────┘  │   │                          │        ▼
│  ┌────────────────────┐  │   │  [Import Button]         │   ┌────────────────┐
│  │ Search Query       │  │   └──────────────────────────┘   │  Transactions  │
│  │ [Text field]       │  │                                  │     Screen     │
│  └────────────────────┘  │                                  │                │
│  ┌────────────────────┐  │                                  │  Imported txns │
│  │ Max Results        │  │                                  │   displayed    │
│  │ [Slider: 10-500]   │  │                                  └────────────────┘
│  └────────────────────┘  │
│                          │
│  [Apply Filters Button]  │
│  [Clear All Button]      │
└──────────────────────────┘
```

---

## 🔄 User Journey Scenarios

### Scenario 1: First Time User

```
1. User taps "Email Parser" from Bank Import Home
   ↓
2. Sees empty state (No Accounts)
   ↓
3. Taps "Connect Email Account"
   ↓
4. Fills email, password, selects provider
   ↓
5. Taps "Connect Account"
   ↓
6. Redirected to Email Parser Screen
   ↓
7. Sees connected account, taps "Fetch Emails" FAB
   ↓
8. Email list loads, taps "Parse Emails" FAB
   ↓
9. Transactions parsed, auto-selected
   ↓
10. Taps "Import Selected" FAB
    ↓
11. Confirms import
    ↓
12. Redirected to Transactions Screen
```

### Scenario 2: Returning User with Account

```
1. User opens Email Parser Screen
   ↓
2. Sees connected accounts and previous emails
   ↓
3. Pulls down to refresh (fetch new emails)
   ↓
4. New emails appear, auto-parsed
   ↓
5. Taps filter button
   ↓
6. Selects specific banks and date range
   ↓
7. Applies filters
   ↓
8. Email list updates
   ↓
9. Selects specific emails
   ↓
10. Imports selected transactions
```

### Scenario 3: Multi-Account User

```
1. User opens Email Parser Screen
   ↓
2. Sees multiple connected accounts
   ↓
3. Taps "Add" to connect another account
   ↓
4. Completes Email Setup for new account
   ↓
5. Returns to parser, selects new account
   ↓
6. Fetches emails from new account
   ↓
7. Parses and imports transactions
   ↓
8. Switches to different account
   ↓
9. Repeats fetch/parse/import cycle
```

### Scenario 4: Email Details View

```
1. User sees email list
   ↓
2. Taps on an email card
   ↓
3. Email Details Screen opens
   ↓
4. Views full email content
   ↓
5. Sees parsed transaction (if available)
   ↓
6. Views attachments list
   ↓
7. Taps import button (future feature)
   ↓
8. Transaction imported individually
```

---

## 📱 Screen States

### Email Parser Screen States

#### State 1: No Accounts
```
┌─────────────────────┐
│   Email Parser      │
├─────────────────────┤
│                     │
│   [Empty State]     │
│                     │
│   • Large Icon      │
│   • Title           │
│   • Description     │
│   • Connect Button  │
│                     │
└─────────────────────┘
```

#### State 2: Has Accounts, No Emails
```
┌─────────────────────┐
│   Email Parser      │
├─────────────────────┤
│ Connected Accounts  │
│ [Account Cards]     │
├─────────────────────┤
│                     │
│   [Empty State]     │
│                     │
│   • No Emails       │
│   • Fetch Button    │
│                     │
└─────────────────────┘
     [FAB: Fetch]
```

#### State 3: Has Emails, Unparsed
```
┌─────────────────────┐
│   Email Parser      │
├─────────────────────┤
│ Connected Accounts  │
│ [Account Cards]     │
├─────────────────────┤
│ Statistics          │
│ Total: 50           │
│ Parsed: 0           │
│ Failed: 0           │
│ Selected: 0         │
├─────────────────────┤
│ Email List          │
│ [Unparsed Cards]    │
│ [Unparsed Cards]    │
│ ...                 │
└─────────────────────┘
     [FAB: Parse]
```

#### State 4: Has Emails, Parsed
```
┌─────────────────────┐
│   Email Parser      │
├─────────────────────┤
│ Connected Accounts  │
│ [Account Cards]     │
├─────────────────────┤
│ Active Filters      │
│ [Filter Chips]      │
├─────────────────────┤
│ Statistics          │
│ Total: 50           │
│ Parsed: 45          │
│ Failed: 5           │
│ Selected: 10        │
├─────────────────────┤
│ Email List          │
│ ☑ [Parsed Card]     │
│ ☑ [Parsed Card]     │
│ ☐ [Parsed Card]     │
│ ✗ [Failed Card]     │
│ ...                 │
└─────────────────────┘
    [FAB: Import 10]
```

#### State 5: Loading
```
┌─────────────────────┐
│   Email Parser      │
├─────────────────────┤
│                     │
│   [Shimmer Cards]   │
│   [Shimmer Cards]   │
│   [Shimmer Cards]   │
│                     │
│     Loading...      │
│                     │
└─────────────────────┘
    [FAB: Loading]
```

---

## 🎯 Widget Hierarchy

### Email Parser Screen

```
EmailParserScreen
├── Scaffold
│   ├── AppBar
│   │   ├── Title: "Email Parser"
│   │   ├── Leading: Back button
│   │   └── Actions
│   │       ├── Filter button
│   │       └── Select All button
│   ├── Body: RefreshIndicator
│   │   └── CustomScrollView
│   │       ├── SliverToBoxAdapter: Connected Accounts
│   │       │   └── Column
│   │       │       ├── Header row (title + Add button)
│   │       │       └── List of EmailAccountCard
│   │       ├── SliverToBoxAdapter: Active Filters
│   │       │   └── Wrap of EmailFilterChip
│   │       ├── SliverToBoxAdapter: Statistics
│   │       │   └── EmailStatsRow
│   │       ├── SliverList: Email List
│   │       │   └── EmailMessageCard (itemBuilder)
│   │       └── SliverPadding: Bottom spacing
│   └── FloatingActionButton: Context-aware
│       ├── Fetch Emails
│       ├── Parse Emails
│       └── Import Selected
```

### Email Setup Screen

```
EmailSetupScreen
├── Scaffold
│   ├── AppBar
│   │   ├── Title: "Connect Email Account"
│   │   └── Leading: Back button
│   └── Body: Form
│       └── ListView
│           ├── Info Card (app password reminder)
│           ├── Email Field
│           ├── Password Field
│           ├── Provider Dropdown
│           ├── Advanced Settings Toggle
│           ├── IMAP Server Field (conditional)
│           ├── IMAP Port Field (conditional)
│           ├── Help Section Card
│           └── Connect Button
```

### Email Filters Screen

```
EmailFiltersScreen (Modal Bottom Sheet)
├── Container
│   ├── Header
│   │   ├── Title: "Email Filters"
│   │   ├── Clear All button
│   │   └── Close button
│   ├── Content: ListView
│   │   ├── Banks Section
│   │   │   └── Wrap of FilterChip
│   │   ├── Date Range Section
│   │   │   └── Tap to open date picker
│   │   ├── Email Types Section
│   │   │   └── CheckboxListTile list
│   │   ├── Include Attachments Toggle
│   │   ├── Search Query Field
│   │   └── Max Results Slider
│   └── Bottom Sheet: Apply Button
```

### Email Details Screen

```
EmailDetailsScreen
├── Scaffold
│   ├── AppBar
│   │   ├── Title: "Email Details"
│   │   ├── Leading: Back button
│   │   └── Actions: Import button
│   └── Body: ListView
│       ├── Email Header Card
│       │   ├── Subject
│       │   ├── From row
│       │   ├── Date row
│       │   ├── Type row
│       │   ├── Bank row (conditional)
│       │   └── Read status row
│       ├── Parsed Transaction Section (conditional)
│       │   └── ParsedTransactionCard
│       ├── Email Content Section
│       │   └── Selectable text
│       └── Attachments Section (conditional)
│           └── List of attachment cards
```

---

## 🎨 Visual States

### Loading States
- Shimmer loading cards
- Progress indicators
- Disabled buttons
- Loading text

### Error States
- Error SnackBars
- Error messages in cards
- Failed status badges
- Retry buttons

### Empty States
- No accounts
- No emails
- No filters
- No attachments

### Success States
- Success SnackBars
- Parsed status badges
- Selected borders
- Import confirmation

---

## 🔗 Dependencies Between Screens

```
EmailParserScreen
    ├─► EmailSetupScreen (push)
    ├─► EmailFiltersScreen (modal)
    ├─► EmailDetailsScreen (push)
    └─► TransactionsScreen (go)

EmailSetupScreen
    └─► EmailParserScreen (pop on success)

EmailFiltersScreen
    └─► EmailParserScreen (pop with filters)

EmailDetailsScreen
    └─► TransactionsScreen (future: import single)
```

---

**Screen Flow Documentation Complete!**
Use this guide to understand the navigation and user journey through the Email Parser feature.
