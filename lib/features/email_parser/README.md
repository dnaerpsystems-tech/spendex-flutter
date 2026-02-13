# Email Statement Parser Feature

## Overview
The Email Statement Parser feature allows users to import bank transactions from their email accounts. It connects to email accounts via IMAP, fetches bank-related emails, parses them to extract transaction information, and imports them into Spendex.

## Architecture
Following Clean Architecture principles with three layers:

```
email_parser/
├── data/
│   ├── models/              # Data models
│   ├── datasources/         # Data sources (Remote & Local)
│   └── repositories/        # Repository implementations
├── domain/
│   └── repositories/        # Repository interfaces
└── presentation/
    └── providers/           # Riverpod state management
```

## Features Implemented

### Task #20: Data Models ✅

#### 1. EmailAccountModel
- Represents an email account connection
- Fields: id, email, provider, displayName, isConnected, lastSyncDate
- IMAP configuration: imapServer, imapPort, username, encryptedPassword, useSsl
- Helper methods:
  - `getDefaultImapConfig()` - Returns default IMAP settings for Gmail, Outlook, Yahoo, iCloud
  - `detectProvider()` - Auto-detects provider from email address
- Supports: Gmail, Outlook, Yahoo, iCloud, and custom providers

#### 2. EmailMessageModel
- Represents an email message
- Fields: id, from, subject, body, date
- Attachment support: hasAttachment, attachments (List<EmailAttachment>)
- Parse state: isRead, isParsed, parseStatus, parsedTransaction
- Email classification: emailType (notification/statement/receipt)
- Bank detection: bankName
- Helper methods:
  - `isFromBank` - Checks if email is from a bank
  - `isFinancial` - Checks if email contains financial keywords
  - `getAttachmentSizeFormatted()` - Returns human-readable attachment size

#### 3. EmailFilterModel
- Controls email fetching filters
- Fields: selectedBanks, dateRange, includeAttachments, emailTypes
- Additional filters: onlyUnparsed, searchQuery, maxResults
- Helper methods:
  - `isEmpty` - Check if filters are default
  - `activeFilterCount` - Count active filters for UI badge
- Factory constructors for common filters:
  - `defaultFilter()` - Last 30 days
  - `lastWeek()` - Last 7 days
  - `lastMonth()` - Last 30 days
  - `lastThreeMonths()` - Last 90 days
  - `currentYear()` - Current year to date

### Task #21: Datasources ✅

#### 1. EmailRemoteDataSource
**Interface + Implementation**

Methods:
- `connectEmailAccount()` - Connect and save account to backend
- `fetchEmails()` - Fetch emails from backend (previously synced)
- `parseEmailTransaction()` - Parse email to extract transaction
- `disconnectAccount()` - Disconnect email account
- `syncAccountStatus()` - Sync account status from backend
- `getConnectedAccounts()` - Get all connected accounts
- `bulkImportTransactions()` - Import parsed transactions
- `toggleEmailTracking()` - Enable/disable email tracking

Returns: `Either<Failure, T>` for all methods

#### 2. EmailLocalDataSource
**Interface + Implementation**

Methods:
- `cacheEmailAccounts()` - Cache accounts locally (secure storage)
- `getCachedAccounts()` - Get cached accounts
- `cacheEmails()` - Cache emails locally
- `getCachedEmails()` - Get cached emails (with optional accountId filter)
- `clearCache()` - Clear all cached data
- `clearEmailsForAccount()` - Clear emails for specific account
- `fetchEmailsFromImap()` - Fetch emails directly from IMAP server
- `saveAccountPassword()` - Save encrypted password
- `getAccountPassword()` - Get decrypted password
- `deleteAccountPassword()` - Delete stored password

IMAP Features:
- Uses `enough_mail` package for IMAP communication
- Connects to IMAP server with SSL support
- Searches emails based on filters (date range, search query)
- Converts MIME messages to EmailMessageModel
- Extracts attachments with metadata
- Auto-detects email type and bank name
- Supports bank patterns for major Indian banks

Returns: `Either<Failure, T>` for all methods

### Task #22: Repository ✅

#### EmailParserRepository
**Interface + Implementation**

Methods:
- `connectAccount()` - Connect email account (auto-detects provider)
- `disconnectAccount()` - Disconnect and cleanup account
- `getAccounts()` - Get all connected accounts (backend + cache fallback)
- `fetchEmails()` - Fetch emails via IMAP with filters
- `parseEmail()` - Parse single email
- `bulkParseEmails()` - Parse multiple emails
- `getFilters()` - Get current filters
- `updateFilters()` - Update filters
- `bulkImportTransactions()` - Import transactions to backend
- `syncAccountStatus()` - Sync account status
- `toggleEmailTracking()` - Toggle email tracking
- `getCachedEmails()` - Get cached emails
- `clearCache()` - Clear cache

Implementation Features:
- Coordinates between remote and local data sources
- Auto-detects email provider from email address
- Saves encrypted passwords securely
- Caches accounts and emails locally
- Falls back to cache when backend is unavailable
- Handles cleanup on account disconnection

### Task #23: Provider ✅

#### EmailParserProvider (Riverpod StateNotifier)

**State Management:**
- `EmailParserState` - Equatable state class
- `EmailParserNotifier` - StateNotifier for business logic

**State Fields:**
- `connectionStatus` - Connection state (idle/connecting/connected/failed)
- `isLoadingAccounts` - Loading accounts flag
- `isFetchingEmails` - Fetching emails flag
- `isParsing` - Parsing emails flag
- `isImporting` - Importing transactions flag
- `accounts` - List of connected accounts
- `selectedAccountId` - Currently selected account
- `emails` - List of fetched emails
- `selectedEmailIds` - Set of selected email IDs
- `filters` - Current filters
- `error` - Error message
- `successMessage` - Success message

**Methods:**
- `loadAccounts()` - Load connected accounts
- `loadFilters()` - Load filters
- `connectAccount()` - Connect new account
- `disconnectAccount()` - Disconnect account
- `selectAccount()` - Select account
- `fetchEmails()` - Fetch emails from selected account
- `parseEmails()` - Parse fetched emails
- `toggleEmailSelection()` - Toggle email selection
- `selectAllEmails()` - Select all parsed emails
- `deselectAllEmails()` - Deselect all emails
- `updateFilters()` - Update filters
- `importTransactions()` - Import selected transactions
- `syncAccountStatus()` - Sync account status
- `toggleEmailTracking()` - Toggle email tracking
- `clearEmails()` - Clear emails
- `clearError()` - Clear error
- `clearSuccessMessage()` - Clear success message

**Computed Providers:**
- `selectedAccountProvider` - Currently selected account
- `selectedEmailCountProvider` - Count of selected emails
- `parsedEmailCountProvider` - Count of parsed emails
- `failedEmailCountProvider` - Count of failed emails
- `selectedEmailsTotalProvider` - Total amount of selected transactions
- `allEmailsSelectedProvider` - Whether all emails are selected
- `hasConnectedAccountsProvider` - Whether user has connected accounts
- `emailStatsProvider` - Email statistics (total/parsed/failed/unparsed/selected)

## Dependencies

All dependencies are already included in `pubspec.yaml`:
- `enough_mail: ^2.1.6` - IMAP email client
- `uuid: ^4.3.1` - UUID generation
- `dartz: ^0.10.1` - Functional programming (Either)
- `equatable: ^2.0.5` - Value equality
- `flutter_riverpod: ^2.4.9` - State management
- `flutter_secure_storage: ^9.0.0` - Secure password storage
- `get_it: ^7.6.7` - Dependency injection

## Dependency Injection

Registered in `lib/core/di/injection.dart`:

```dart
// Data Sources
EmailRemoteDataSource -> EmailRemoteDataSourceImpl
EmailLocalDataSource -> EmailLocalDataSourceImpl

// Repository
EmailParserRepository -> EmailParserRepositoryImpl
```

## API Endpoints

Backend endpoints used (all prefixed with `/api/v1`):

```
POST   /email/connect              - Connect email account
POST   /email/fetch                - Fetch emails
POST   /email/parse                - Parse email transaction
DELETE /email/disconnect/:id       - Disconnect account
GET    /email/accounts/:id/sync    - Sync account status
GET    /email/accounts             - Get connected accounts
POST   /transactions/bulk-import   - Import transactions
PUT    /email/accounts/:id/tracking - Toggle tracking
```

## Supported Email Providers

### Pre-configured:
1. **Gmail** - `imap.gmail.com:993`
2. **Outlook/Hotmail/Live** - `outlook.office365.com:993`
3. **Yahoo** - `imap.mail.yahoo.com:993`
4. **iCloud** - `imap.mail.me.com:993`
5. **Custom** - Manual IMAP configuration

### Auto-detection:
Provider is automatically detected from email address domain.

## Supported Banks

The system can detect emails from major Indian banks:
- State Bank of India (SBI)
- HDFC Bank
- ICICI Bank
- Axis Bank
- Kotak Mahindra Bank
- Bank of Baroda
- Punjab National Bank
- Canara Bank
- Union Bank of India
- Yes Bank
- IndusInd Bank
- IDFC First Bank

## Email Classification

Emails are automatically classified into types:
1. **Notification** - Transaction alerts (debit/credit/UPI)
2. **Statement** - Bank statements
3. **Receipt** - Purchase receipts/invoices
4. **Other** - Unclassified emails

## Security

1. **Password Encryption**: Email passwords are encrypted using FlutterSecureStorage
2. **Secure Storage**: All sensitive data stored in secure storage
3. **SSL/TLS**: IMAP connections use SSL by default
4. **No Plain Text**: Passwords never stored in plain text

## Usage Example

```dart
// 1. Get the provider
final emailParserNotifier = ref.read(emailParserProvider.notifier);

// 2. Connect an account
await emailParserNotifier.connectAccount(
  email: 'user@gmail.com',
  password: 'app-specific-password',
);

// 3. Fetch emails
await emailParserNotifier.fetchEmails();

// 4. Parse emails
await emailParserNotifier.parseEmails();

// 5. Select emails
emailParserNotifier.selectAllEmails();

// 6. Import transactions
await emailParserNotifier.importTransactions();
```

## Next Steps (Tasks #24-27)

The following UI components need to be implemented:

### Task #24: Connect Email Account Screen
- Email input field
- Password input field
- Provider selection
- Custom IMAP configuration (advanced)

### Task #25: Email List Screen
- List of connected accounts
- Email filters
- Email list with parse status
- Email selection

### Task #26: Email Details Screen
- Email content display
- Parsed transaction details
- Edit parsed transaction

### Task #27: Import Confirmation Screen
- Selected emails summary
- Total amount
- Import confirmation
- Success/error feedback

## Notes

- No mock data - Full API integration
- Type-safe with null-safety
- Proper error handling with Either<Failure, T>
- Follows existing patterns from bank_import feature
- Professional validation and business logic
- Production-ready code

## Testing

To test the feature:
1. Ensure backend API is running
2. Use app-specific passwords for Gmail (not regular password)
3. Enable IMAP in email account settings
4. Test with different email providers
5. Verify email parsing accuracy
6. Check transaction import success

## Troubleshooting

Common issues:
1. **Connection failed**: Check IMAP server/port settings
2. **Authentication failed**: Use app-specific password
3. **No emails found**: Check date range filter
4. **Parsing failed**: Email format not recognized
5. **Import failed**: Backend API issue

## Files Created

```
lib/features/email_parser/
├── data/
│   ├── models/
│   │   ├── email_account_model.dart
│   │   ├── email_message_model.dart
│   │   └── email_filter_model.dart
│   ├── datasources/
│   │   ├── email_remote_datasource.dart
│   │   └── email_local_datasource.dart
│   └── repositories/
│       └── email_parser_repository_impl.dart
├── domain/
│   └── repositories/
│       └── email_parser_repository.dart
├── presentation/
│   └── providers/
│       └── email_parser_provider.dart
├── email_parser_exports.dart
└── README.md
```

## Status

✅ Task #20: Data Models - Complete
✅ Task #21: Datasources - Complete
✅ Task #22: Repository - Complete
✅ Task #23: Provider - Complete
⏳ Task #24-27: UI Screens - Pending

All data/domain/presentation layers are complete and production-ready!
