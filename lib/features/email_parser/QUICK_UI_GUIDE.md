# Email Parser UI - Quick Reference Guide

## 🚀 Quick Start

### 1. Import Everything
```dart
import 'package:spendex/features/email_parser/presentation/email_parser_ui_exports.dart';
```

### 2. Navigate to Email Parser
```dart
// From anywhere in the app
context.push('/email-parser');
```

---

## 📱 Available Screens

### EmailParserScreen (Main Screen)
```dart
const EmailParserScreen()
```
- Main email parser interface
- Shows connected accounts
- Displays email list with filters
- Select and import transactions
- Pull-to-refresh support

**Route:** `/email-parser`

### EmailSetupScreen
```dart
const EmailSetupScreen()
```
- Connect new email account
- Email + password + provider
- Advanced IMAP settings
- Auto-detect provider

**Usage:** Navigate from EmailParserScreen or directly

### EmailFiltersScreen
```dart
const EmailFiltersScreen()
```
- Modal bottom sheet
- Filter by banks, dates, types
- Search and max results
- Apply/Clear actions

**Usage:** Called from EmailParserScreen via bottom sheet

### EmailDetailsScreen
```dart
EmailDetailsScreen(email: emailMessage)
```
- View full email content
- Show parsed transaction
- Display attachments
- Import single transaction

**Usage:** Navigate with email parameter

---

## 🧩 Available Widgets

### EmailAccountCard
```dart
EmailAccountCard(
  account: account,
  isSelected: true,
  onSelect: () => print('Selected'),
  onDisconnect: () => print('Disconnected'),
)
```
Display connected email account with actions.

### EmailMessageCard
```dart
EmailMessageCard(
  email: email,
  isSelected: false,
  onToggle: () => print('Toggled'),
  onTap: () => print('Tapped'),
)
```
Email item in list with checkbox and preview.

### EmailFilterChip
```dart
EmailFilterChip(
  label: '5 banks',
  icon: Iconsax.bank,
  onRemove: () => print('Removed'),
)
```
Active filter chip with remove action.

### ParsedTransactionCard
```dart
ParsedTransactionCard(
  transaction: transaction,
  bankName: 'HDFC Bank',
)
```
Detailed transaction display from parsed email.

### EmailStatsRow
```dart
EmailStatsRow(
  total: 50,
  parsed: 45,
  failed: 5,
  selected: 10,
)
```
Statistics display (total/parsed/failed/selected).

### EmptyEmailState
```dart
EmptyEmailState(
  onAction: () => print('Fetch'),
)
```
Empty state when no emails available.

---

## 🔌 Provider Usage

### Watch State
```dart
final state = ref.watch(emailParserProvider);
final hasAccounts = ref.watch(hasConnectedAccountsProvider);
final selectedCount = ref.watch(selectedEmailCountProvider);
final parsedCount = ref.watch(parsedEmailCountProvider);
final stats = ref.watch(emailStatsProvider);
```

### Call Actions
```dart
// Connect account
await ref.read(emailParserProvider.notifier).connectAccount(
  email: 'user@gmail.com',
  password: 'app-password',
  provider: EmailProvider.gmail,
);

// Fetch emails
await ref.read(emailParserProvider.notifier).fetchEmails();

// Parse emails
await ref.read(emailParserProvider.notifier).parseEmails();

// Import transactions
final success = await ref.read(emailParserProvider.notifier).importTransactions();

// Update filters
ref.read(emailParserProvider.notifier).updateFilters(filters);

// Select/Deselect
ref.read(emailParserProvider.notifier).toggleEmailSelection(emailId);
ref.read(emailParserProvider.notifier).selectAllEmails();
ref.read(emailParserProvider.notifier).deselectAllEmails();
```

---

## 🎨 Common Patterns

### Show SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success!'),
    backgroundColor: SpendexColors.income,
    behavior: SnackBarBehavior.floating,
  ),
);
```

### Confirmation Dialog
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Confirm Action'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Confirm'),
      ),
    ],
  ),
);

if (confirmed == true) {
  // Proceed
}
```

### Bottom Sheet
```dart
await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => const EmailFiltersScreen(),
);
```

---

## 🎯 Color Coding

### Status Colors
```dart
ParseStatus.parsed    → SpendexColors.income   (green)
ParseStatus.failed    → SpendexColors.expense  (red)
ParseStatus.unparsed  → SpendexColors.warning  (orange)
```

### Transaction Types
```dart
TransactionType.income   → SpendexColors.income   (green)
TransactionType.expense  → SpendexColors.expense  (red)
```

### UI States
```dart
Selected   → SpendexColors.primary border
Connected  → SpendexColors.income badge
```

---

## 📊 Example: Complete Flow

```dart
class MyEmailImportPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emailParserProvider);
    final stats = ref.watch(emailStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Email Import')),
      body: Column(
        children: [
          // Stats
          EmailStatsRow(
            total: stats['total']!,
            parsed: stats['parsed']!,
            failed: stats['failed']!,
            selected: stats['selected']!,
          ),

          // Email list
          Expanded(
            child: ListView.builder(
              itemCount: state.emails.length,
              itemBuilder: (context, index) {
                final email = state.emails[index];
                return EmailMessageCard(
                  email: email,
                  isSelected: state.selectedEmailIds.contains(email.id),
                  onToggle: () {
                    ref.read(emailParserProvider.notifier)
                      .toggleEmailSelection(email.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final success = await ref.read(emailParserProvider.notifier)
            .importTransactions();

          if (success) {
            context.go('/home/transactions');
          }
        },
        label: Text('Import ${stats['selected']}'),
        icon: const Icon(Iconsax.tick_circle),
      ),
    );
  }
}
```

---

## 🔍 Debugging

### Check Provider State
```dart
print('Accounts: ${state.accounts.length}');
print('Emails: ${state.emails.length}');
print('Selected: ${state.selectedEmailIds.length}');
print('Loading: ${state.isFetchingEmails}');
print('Error: ${state.error}');
```

### Check Computed Values
```dart
print('Has Accounts: ${ref.read(hasConnectedAccountsProvider)}');
print('Selected Count: ${ref.read(selectedEmailCountProvider)}');
print('Parsed Count: ${ref.read(parsedEmailCountProvider)}');
print('Stats: ${ref.read(emailStatsProvider)}');
```

---

## 📝 Notes

- Always use `ref.watch` in build method
- Use `ref.read` in callbacks/async methods
- Handle loading/error states
- Show user feedback (SnackBars)
- Confirm destructive actions
- Clear errors after displaying

---

## 🎓 Best Practices

1. **State Management**
   - Watch providers in build
   - Read providers in callbacks
   - Clear errors after showing

2. **User Feedback**
   - Show loading indicators
   - Display success/error SnackBars
   - Confirm destructive actions

3. **Navigation**
   - Use GoRouter for main routes
   - Use Navigator for modals
   - Pop on success/cancel

4. **Error Handling**
   - Check for null values
   - Show error messages
   - Provide retry options

5. **Performance**
   - Use ListView.builder
   - Avoid rebuilding unnecessarily
   - Dispose controllers

---

**Quick Reference Complete!**
Use this guide for rapid development and integration.
