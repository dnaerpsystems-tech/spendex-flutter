# Email Parser - Quick Start Guide

## 🚀 Getting Started

The Email Statement Parser feature allows users to import bank transactions from their email accounts (Gmail, Outlook, Yahoo, iCloud, etc.).

## 📋 Prerequisites

1. **Backend API**: Ensure the backend API endpoints are implemented
2. **Dependencies**: Already included in `pubspec.yaml`
3. **DI Setup**: Already registered in `injection.dart`

## 🔧 Setup

### 1. Import the Feature

```dart
import 'package:spendex/features/email_parser/email_parser_exports.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

### 2. Use in Your Widget

```dart
class YourScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state
    final state = ref.watch(emailParserProvider);

    // Get the notifier for actions
    final notifier = ref.read(emailParserProvider.notifier);

    // Your UI here
  }
}
```

## 📱 Core Workflows

### Workflow 1: Connect Email Account

```dart
// Basic connection (auto-detects Gmail, Outlook, etc.)
final success = await notifier.connectAccount(
  email: 'user@gmail.com',
  password: 'app-specific-password', // NOT regular password!
);

// Custom IMAP connection
final success = await notifier.connectAccount(
  email: 'user@customdomain.com',
  password: 'password',
  provider: EmailProvider.other,
  imapServer: 'imap.customdomain.com',
  imapPort: 993,
);

if (success) {
  // Account connected successfully
  // state.successMessage will contain confirmation
} else {
  // Connection failed
  // state.error will contain error message
}
```

### Workflow 2: Fetch Emails

```dart
// Fetch emails from selected account
await notifier.fetchEmails();

// The emails will be in state.emails
// Check state.isFetchingEmails for loading state
```

### Workflow 3: Parse Emails

```dart
// Parse all fetched emails
await notifier.parseEmails();

// Parsed emails will have:
// - parseStatus: ParseStatus.parsed or ParseStatus.failed
// - parsedTransaction: Contains extracted transaction data
```

### Workflow 4: Import Transactions

```dart
// Select emails first
notifier.toggleEmailSelection(emailId);

// Or select all parsed emails
notifier.selectAllEmails();

// Import selected transactions
final success = await notifier.importTransactions();

if (success) {
  // Transactions imported
  // state.successMessage will show count
}
```

### Workflow 5: Disconnect Account

```dart
final success = await notifier.disconnectAccount(accountId);

if (success) {
  // Account disconnected
  // All related data cleared
}
```

## 🎯 Common Use Cases

### Use Case 1: Simple Email Import

```dart
// 1. Connect account
await notifier.connectAccount(
  email: email,
  password: password,
);

// 2. Fetch recent emails
await notifier.fetchEmails();

// 3. Parse emails
await notifier.parseEmails();

// 4. Select all and import
notifier.selectAllEmails();
await notifier.importTransactions();
```

### Use Case 2: Filtered Email Fetch

```dart
// Update filters first
await notifier.updateFilters(
  EmailFilterModel(
    dateRange: DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 30)),
      end: DateTime.now(),
    ),
    selectedBanks: {'HDFC Bank', 'ICICI Bank'},
    emailTypes: {EmailType.notification},
  ),
);

// Then fetch
await notifier.fetchEmails();
```

### Use Case 3: Manual Email Selection

```dart
// Parse emails first
await notifier.parseEmails();

// Check which emails were successfully parsed
final parsedEmails = state.emails
    .where((e) => e.parseStatus == ParseStatus.parsed);

// Manually select specific emails
for (final email in parsedEmails) {
  if (email.parsedTransaction!.amount > 100) {
    notifier.toggleEmailSelection(email.id);
  }
}

// Import selected ones
await notifier.importTransactions();
```

## 📊 State Access

### Check Loading States

```dart
final state = ref.watch(emailParserProvider);

if (state.isLoadingAccounts) {
  // Show loading for accounts
}

if (state.isFetchingEmails) {
  // Show loading for email fetch
}

if (state.isParsing) {
  // Show parsing progress
}

if (state.isImporting) {
  // Show import progress
}
```

### Access Computed Data

```dart
// Get selected account
final selectedAccount = ref.watch(selectedAccountProvider);

// Get counts
final selectedCount = ref.watch(selectedEmailCountProvider);
final parsedCount = ref.watch(parsedEmailCountProvider);
final failedCount = ref.watch(failedEmailCountProvider);

// Get total amount of selected transactions
final total = ref.watch(selectedEmailsTotalProvider);

// Check if all emails are selected
final allSelected = ref.watch(allEmailsSelectedProvider);

// Check if user has connected accounts
final hasAccounts = ref.watch(hasConnectedAccountsProvider);

// Get statistics
final stats = ref.watch(emailStatsProvider);
// Returns: {total, parsed, failed, unparsed, selected}
```

### Handle Errors

```dart
final state = ref.watch(emailParserProvider);

if (state.error != null) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.error!)),
  );

  // Clear error
  notifier.clearError();
}

if (state.successMessage != null) {
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(state.successMessage!)),
  );

  // Clear message
  notifier.clearSuccessMessage();
}
```

## 🔐 Security Notes

### 1. Use App-Specific Passwords

For Gmail accounts, users must create an app-specific password:
1. Go to Google Account Settings
2. Security → 2-Step Verification
3. App passwords
4. Generate new password
5. Use this password, NOT the regular Google password

### 2. Password Storage

- Passwords are encrypted using FlutterSecureStorage
- Stored in device's secure storage (Keychain on iOS, EncryptedSharedPreferences on Android)
- Never stored in plain text

### 3. IMAP Security

- Always uses SSL/TLS (port 993)
- Secure IMAP connections
- No plain text transmission

## 📝 Filter Examples

### Last 7 Days

```dart
EmailFilterModel.lastWeek()
```

### Last Month

```dart
EmailFilterModel.lastMonth()
```

### Current Year

```dart
EmailFilterModel.currentYear()
```

### Custom Filter

```dart
EmailFilterModel(
  selectedBanks: {'HDFC Bank', 'SBI'},
  dateRange: DateTimeRange(
    start: DateTime(2024, 1, 1),
    end: DateTime(2024, 12, 31),
  ),
  includeAttachments: true,
  emailTypes: {EmailType.notification, EmailType.statement},
  onlyUnparsed: false,
  searchQuery: 'transaction',
  maxResults: 50,
)
```

## 🐛 Troubleshooting

### Problem: Connection Failed

**Solution:**
- Ensure IMAP is enabled in email account settings
- Use app-specific password for Gmail
- Check internet connection
- Verify IMAP server and port settings

### Problem: No Emails Found

**Solution:**
- Check date range filter
- Verify selected banks
- Ensure emails exist in inbox
- Check email types filter

### Problem: Parsing Failed

**Solution:**
- Email format not recognized by backend
- Check email is actually from a bank
- Verify email contains transaction details

### Problem: Import Failed

**Solution:**
- Backend API issue
- Check network connection
- Verify transactions are valid
- Check backend logs

## 🎨 UI Components Needed (Tasks #24-27)

### Task #24: Connect Email Account Screen

```dart
// UI should include:
- Email TextField
- Password TextField (obscure text)
- Provider Dropdown
- Advanced settings (optional IMAP config)
- Connect Button
- Loading indicator
- Error display
```

### Task #25: Email List Screen

```dart
// UI should include:
- Account selector dropdown
- Filter button (opens filter dialog)
- Email list (cards or tiles)
- Checkbox for selection
- Parse status badge
- Pull-to-refresh
- Empty state widget
- Fetch emails button
- Parse emails button
```

### Task #26: Email Details Screen

```dart
// UI should include:
- Email header (from, subject, date)
- Email body
- Attachments list
- Parsed transaction card
- Edit transaction button
- Import single button
```

### Task #27: Import Confirmation Screen

```dart
// UI should include:
- Selected count
- Total amount
- Transaction list preview
- Import button
- Cancel button
- Success/error feedback
```

## 📚 Additional Resources

- Full documentation: `README.md`
- Implementation details: `IMPLEMENTATION_SUMMARY.md`
- API Client: `lib/core/network/api_client.dart`
- Error types: `lib/core/errors/failures.dart`

## 🆘 Support

For issues or questions:
1. Check error messages in `state.error`
2. Review backend API logs
3. Verify IMAP settings
4. Check network connectivity
5. Validate email credentials

## ✅ Checklist for Integration

- [ ] Backend API endpoints implemented
- [ ] User has email account (Gmail/Outlook/etc.)
- [ ] User has app-specific password (for Gmail)
- [ ] IMAP enabled in email settings
- [ ] Internet connection available
- [ ] UI screens implemented
- [ ] Error handling UI ready
- [ ] Success feedback UI ready
- [ ] Loading states handled
- [ ] Testing completed

---

**Happy Coding!** 🚀
