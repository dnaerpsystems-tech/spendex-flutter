/// API Endpoints for Spendex Backend
class ApiEndpoints {
  ApiEndpoints._();
  // Base URL
  static const String baseUrl = 'https://api.spendex.in/api/v1';
  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  // Social Auth
  static const String socialAuth = '/auth/social';
  static const String biometricRegisterOptions = '/auth/biometric/register-options';
  static const String biometricRegister = '/auth/biometric/register';
  static const String biometricLoginOptions = '/auth/biometric/login-options';
  static const String biometricLogin = '/auth/biometric/login';
  static const String biometricCredentials = '/auth/biometric/credentials';
  // Account Management
  static const String deleteAccount = '/auth/delete-account';
  static const String checkSubscription = '/user/subscription/active';
  // Accounts Endpoints
  static const String accounts = '/accounts';
  static const String accountsSummary = '/accounts/summary';
  static String accountById(String id) => '/accounts/$id';
  static const String accountsTransfer = '/accounts/transfer';
  // Transactions Endpoints
  static const String transactions = '/transactions';
  static const String transactionsStats = '/transactions/stats';
  static const String transactionsDaily = '/transactions/daily';
  static String transactionById(String id) => '/transactions/$id';
  // Categories Endpoints
  static const String categories = '/categories';
  static const String categoriesIncome = '/categories/income';
  static const String categoriesExpense = '/categories/expense';
  static const String categoriesSuggest = '/categories/suggest';
  static String categoryById(String id) => '/categories/$id';
  // Budgets Endpoints
  static const String budgets = '/budgets';
  static const String budgetsSummary = '/budgets/summary';
  static String budgetById(String id) => '/budgets/$id';
  // Goals Endpoints
  static const String goals = '/goals';
  static const String goalsSummary = '/goals/summary';
  static String goalById(String id) => '/goals/$id';
  static String goalContributions(String id) => '/goals/$id/contributions';
  // Loans Endpoints
  static const String loans = '/loans';
  static const String loansSummary = '/loans/summary';
  static String loanById(String id) => '/loans/$id';
  static String loanEmiPayment(String id) => '/loans/$id/emi-payment';
  // Investments Endpoints
  static const String investments = '/investments';
  static const String investmentsSummary = '/investments/summary';
  static String investmentsTax(String year) => '/investments/tax/$year';
  static String investmentById(String id) => '/investments/$id';
  static const String investmentsSyncPrices = '/investments/sync-prices';
  // Subscription Endpoints
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String subscriptionCurrent = '/subscriptions/current';
  static const String subscriptionUsage = '/subscriptions/usage';
  static const String subscriptionCheckout = '/subscriptions/checkout';
  static const String subscriptionVerifyPayment = '/subscriptions/verify-payment';
  static const String subscriptionUpgrade = '/subscriptions/upgrade';
  static const String subscriptionDowngrade = '/subscriptions/downgrade';
  static const String subscriptionCancel = '/subscriptions/cancel';
  static const String subscriptionResume = '/subscriptions/resume';
  static const String subscriptionInvoices = '/subscriptions/invoices';
  static String subscriptionInvoiceDownload(String id) => '/subscriptions/invoices/$id/download';
  static const String subscriptionUpiCreate = '/subscriptions/upi/create';
  static const String subscriptionUpiVerify = '/subscriptions/upi/verify';
  static const String subscriptionPayments = '/subscriptions/payments';
  // Family Endpoints
  static const String family = '/family';
  static const String familyInvite = '/family/invite';
  static String familyAcceptInvite(String token) => '/family/invites/$token/accept';
  static String familyCancelInvite(String id) => '/family/invites/$id';
  static String familyMember(String id) => '/family/members/$id';
  static const String familyLeave = '/family/leave';
  static const String familyTransferOwnership = '/family/transfer-ownership';
  // Insights Endpoints
  static const String insights = '/insights';
  static const String insightsDashboard = '/insights/dashboard';
  static const String insightsGenerate = '/insights/generate';
  static String insightById(String id) => '/insights/$id';
  static String insightMarkRead(String id) => '/insights/$id/read';
  static String insightDismiss(String id) => '/insights/$id/dismiss';
  // Voice Endpoints
  static const String voiceTranscribe = '/voice/transcribe';
  static const String voiceParse = '/voice/parse';
  static const String voiceTranscribeAndParse = '/voice/transcribe-and-parse';
  // Receipt Endpoints
  static const String receiptsScan = '/receipts/scan';
  static const String receiptsParse = '/receipts/parse';
  // Sync Endpoints
  static const String syncPush = '/sync/push';
  static const String syncPull = '/sync/pull';
  static const String syncStatus = '/sync/status';
  static String syncConflictResolve(String id) => '/sync/conflicts/$id/resolve';
  // Notifications Endpoints
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationDelete(String id) => '/notifications/$id';
  static const String notificationsRegisterPush = '/notifications/register-push';
  // Bank Import - PDF/CSV Import Endpoints
  static const String importPdf = '/import/pdf';
  static const String importCsv = '/import/csv';
  static const String importHistory = '/import/history';
  static String importResults(String importId) => '/import/$importId/results';
  static String importConfirm(String importId) => '/import/$importId/confirm';
  static String importDelete(String importId) => '/import/$importId';
  // Bank Import - SMS Parser Endpoints
  static const String smsSyncMessages = '/sms/sync';
  static const String smsBankConfigs = '/sms/bank-configs';
  static const String smsTracking = '/sms/tracking';
  static const String transactionsBulkImport = '/transactions/bulk-import';
  // Bank Import - Account Aggregator Endpoints
  static const String aaConsentInitiate = '/aa/consent/initiate';
  static String aaConsentStatus(String consentId) => '/aa/consent/$consentId/status';
  static String aaConsentRevoke(String consentId) => '/aa/consent/$consentId/revoke';
  static const String aaDataFetch = '/aa/data/fetch';
  static const String aaAccounts = '/aa/accounts';
  // Bank Import - India Utils Endpoints
  static String utilsIfscLookup(String ifscCode) => '/utils/ifsc/$ifscCode';
  static const String utilsUpiValidate = '/utils/upi/validate';
  static const String utilsPaymentMethods = '/utils/payment-methods';
  // Bank Import - Email Parser Endpoints
  static const String emailConnect = '/email/connect';
  static const String emailDisconnect = '/email/disconnect';
  static const String emailAccounts = '/email/accounts';
  static String emailAccountById(String id) => '/email/accounts/$id';
  static const String emailFetch = '/email/fetch';
  static const String emailParse = '/email/parse';
  static String emailById(String id) => '/email/$id';
  static const String emailBulkImport = '/email/bulk-import';
  static const String emailBankConfigs = '/email/bank-configs';
  // Duplicate Detection Endpoints
  static const String duplicateCheck = '/transactions/check-duplicates';
  static const String duplicateResolve = '/transactions/resolve-duplicates';
  static const String duplicateStats = '/transactions/duplicate-stats';
  // Analytics Endpoints
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsIncome = '/analytics/income';
  static const String analyticsExpense = '/analytics/expense';
  static const String analyticsTrends = '/analytics/trends';
  static const String analyticsNetWorth = '/analytics/net-worth';
  static const String analyticsExport = '/analytics/export';
  static const String analyticsCategoryBreakdown = '/analytics/category-breakdown';
  static const String analyticsMonthlyStats = '/analytics/monthly-stats';
  static const String analyticsDailyStats = '/analytics/daily-stats';
}
