/// Analytics event names and parameter constants for consistent tracking.
///
/// This file defines all analytics events used throughout the Spendex app.
/// Using constants ensures consistency and prevents typos in event names.
class AnalyticsEvents {
  AnalyticsEvents._();

  // ============================================================
  // Screen Names
  // ============================================================

  /// Dashboard/Home screen
  static const String screenDashboard = 'dashboard';

  /// Transactions list screen
  static const String screenTransactions = 'transactions';

  /// Transaction details screen
  static const String screenTransactionDetails = 'transaction_details';

  /// Add/Edit transaction screen
  static const String screenAddTransaction = 'add_transaction';

  /// Accounts list screen
  static const String screenAccounts = 'accounts';

  /// Account details screen
  static const String screenAccountDetails = 'account_details';

  /// Add/Edit account screen
  static const String screenAddAccount = 'add_account';

  /// Categories screen
  static const String screenCategories = 'categories';

  /// Category details screen
  static const String screenCategoryDetails = 'category_details';

  /// Budgets list screen
  static const String screenBudgets = 'budgets';

  /// Budget details screen
  static const String screenBudgetDetails = 'budget_details';

  /// Add/Edit budget screen
  static const String screenAddBudget = 'add_budget';

  /// Goals list screen
  static const String screenGoals = 'goals';

  /// Goal details screen
  static const String screenGoalDetails = 'goal_details';

  /// Add/Edit goal screen
  static const String screenAddGoal = 'add_goal';

  /// Investments screen
  static const String screenInvestments = 'investments';

  /// Investment details screen
  static const String screenInvestmentDetails = 'investment_details';

  /// Add/Edit investment screen
  static const String screenAddInvestment = 'add_investment';

  /// Loans screen
  static const String screenLoans = 'loans';

  /// Loan details screen
  static const String screenLoanDetails = 'loan_details';

  /// Add/Edit loan screen
  static const String screenAddLoan = 'add_loan';

  /// Insights/Analytics screen
  static const String screenInsights = 'insights';

  /// Reports screen
  static const String screenReports = 'reports';

  /// Settings screen
  static const String screenSettings = 'settings';

  /// Profile screen
  static const String screenProfile = 'profile';

  /// Notifications screen
  static const String screenNotifications = 'notifications';

  /// Subscription/Premium screen
  static const String screenSubscription = 'subscription';

  /// Family management screen
  static const String screenFamily = 'family';

  /// Bank import screen
  static const String screenBankImport = 'bank_import';

  /// SMS import screen
  static const String screenSmsImport = 'sms_import';

  /// PDF import screen
  static const String screenPdfImport = 'pdf_import';

  /// Email import screen
  static const String screenEmailImport = 'email_import';

  /// Account aggregator screen
  static const String screenAccountAggregator = 'account_aggregator';

  /// Duplicate detection screen
  static const String screenDuplicateDetection = 'duplicate_detection';

  /// Login screen
  static const String screenLogin = 'login';

  /// Sign up screen
  static const String screenSignUp = 'sign_up';

  /// Forgot password screen
  static const String screenForgotPassword = 'forgot_password';

  /// Onboarding screen
  static const String screenOnboarding = 'onboarding';

  /// PIN setup screen
  static const String screenPinSetup = 'pin_setup';

  /// PIN entry screen
  static const String screenPinEntry = 'pin_entry';

  /// Biometric setup screen
  static const String screenBiometricSetup = 'biometric_setup';

  // ============================================================
  // Authentication Events
  // ============================================================

  /// User logged in
  static const String eventLogin = 'login';

  /// User signed up
  static const String eventSignUp = 'sign_up';

  /// User logged out
  static const String eventLogout = 'logout';

  /// Password reset requested
  static const String eventPasswordResetRequest = 'password_reset_request';

  /// Password reset completed
  static const String eventPasswordResetComplete = 'password_reset_complete';

  /// User deleted account
  static const String eventUserAccountDeleted = 'user_account_deleted';

  // ============================================================
  // Transaction Events
  // ============================================================

  /// Transaction created
  static const String eventTransactionCreated = 'transaction_created';

  /// Transaction updated
  static const String eventTransactionUpdated = 'transaction_updated';

  /// Transaction deleted
  static const String eventTransactionDeleted = 'transaction_deleted';

  /// Transaction imported (SMS/PDF/Email)
  static const String eventTransactionImported = 'transaction_imported';

  /// Transaction categorized
  static const String eventTransactionCategorized = 'transaction_categorized';

  /// Transaction split
  static const String eventTransactionSplit = 'transaction_split';

  /// Recurring transaction created
  static const String eventRecurringTransactionCreated = 'recurring_transaction_created';

  // ============================================================
  // Account Events
  // ============================================================

  /// Account created
  static const String eventAccountCreated = 'account_created';

  /// Account updated
  static const String eventAccountUpdated = 'account_updated';

  /// Account deleted
  static const String eventAccountDeleted = 'account_deleted';

  /// Account balance updated
  static const String eventAccountBalanceUpdated = 'account_balance_updated';

  /// Account linked (via aggregator)
  static const String eventAccountLinked = 'account_linked';

  /// Account unlinked
  static const String eventAccountUnlinked = 'account_unlinked';

  // ============================================================
  // Budget Events
  // ============================================================

  /// Budget created
  static const String eventBudgetCreated = 'budget_created';

  /// Budget updated
  static const String eventBudgetUpdated = 'budget_updated';

  /// Budget deleted
  static const String eventBudgetDeleted = 'budget_deleted';

  /// Budget exceeded
  static const String eventBudgetExceeded = 'budget_exceeded';

  /// Budget warning (approaching limit)
  static const String eventBudgetWarning = 'budget_warning';

  /// Budget achieved (under budget)
  static const String eventBudgetAchieved = 'budget_achieved';

  // ============================================================
  // Goal Events
  // ============================================================

  /// Goal created
  static const String eventGoalCreated = 'goal_created';

  /// Goal updated
  static const String eventGoalUpdated = 'goal_updated';

  /// Goal deleted
  static const String eventGoalDeleted = 'goal_deleted';

  /// Goal achieved
  static const String eventGoalAchieved = 'goal_achieved';

  /// Goal contribution added
  static const String eventGoalContribution = 'goal_contribution';

  /// Goal progress milestone (25%, 50%, 75%)
  static const String eventGoalMilestone = 'goal_milestone';

  // ============================================================
  // Category Events
  // ============================================================

  /// Category created
  static const String eventCategoryCreated = 'category_created';

  /// Category updated
  static const String eventCategoryUpdated = 'category_updated';

  /// Category deleted
  static const String eventCategoryDeleted = 'category_deleted';

  // ============================================================
  // Investment Events
  // ============================================================

  /// Investment created
  static const String eventInvestmentCreated = 'investment_created';

  /// Investment updated
  static const String eventInvestmentUpdated = 'investment_updated';

  /// Investment deleted
  static const String eventInvestmentDeleted = 'investment_deleted';

  /// Investment revalued
  static const String eventInvestmentRevalued = 'investment_revalued';

  // ============================================================
  // Loan Events
  // ============================================================

  /// Loan created
  static const String eventLoanCreated = 'loan_created';

  /// Loan updated
  static const String eventLoanUpdated = 'loan_updated';

  /// Loan deleted
  static const String eventLoanDeleted = 'loan_deleted';

  /// Loan payment made
  static const String eventLoanPayment = 'loan_payment';

  /// Loan paid off
  static const String eventLoanPaidOff = 'loan_paid_off';

  // ============================================================
  // Import Events
  // ============================================================

  /// SMS import started
  static const String eventSmsImportStarted = 'sms_import_started';

  /// SMS import completed
  static const String eventSmsImportCompleted = 'sms_import_completed';

  /// PDF import started
  static const String eventPdfImportStarted = 'pdf_import_started';

  /// PDF import completed
  static const String eventPdfImportCompleted = 'pdf_import_completed';

  /// Email import started
  static const String eventEmailImportStarted = 'email_import_started';

  /// Email import completed
  static const String eventEmailImportCompleted = 'email_import_completed';

  /// Account aggregator connected
  static const String eventAggregatorConnected = 'aggregator_connected';

  /// Account aggregator sync
  static const String eventAggregatorSync = 'aggregator_sync';

  /// Duplicate detected
  static const String eventDuplicateDetected = 'duplicate_detected';

  /// Duplicate merged
  static const String eventDuplicateMerged = 'duplicate_merged';

  /// Duplicate ignored
  static const String eventDuplicateIgnored = 'duplicate_ignored';

  // ============================================================
  // Subscription Events
  // ============================================================

  /// Subscription started
  static const String eventSubscriptionStarted = 'subscription_started';

  /// Subscription renewed
  static const String eventSubscriptionRenewed = 'subscription_renewed';

  /// Subscription cancelled
  static const String eventSubscriptionCancelled = 'subscription_cancelled';

  /// Subscription expired
  static const String eventSubscriptionExpired = 'subscription_expired';

  /// Trial started
  static const String eventTrialStarted = 'trial_started';

  /// Trial ended
  static const String eventTrialEnded = 'trial_ended';

  /// Paywall viewed
  static const String eventPaywallViewed = 'paywall_viewed';

  /// Feature gated (user hit premium wall)
  static const String eventFeatureGated = 'feature_gated';

  /// Feature used (custom feature tracking)
  static const String eventFeatureUsed = 'feature_used';

  // ============================================================
  // Family Events
  // ============================================================

  /// Family created
  static const String eventFamilyCreated = 'family_created';

  /// Family member invited
  static const String eventFamilyMemberInvited = 'family_member_invited';

  /// Family member joined
  static const String eventFamilyMemberJoined = 'family_member_joined';

  /// Family member removed
  static const String eventFamilyMemberRemoved = 'family_member_removed';

  /// Family left
  static const String eventFamilyLeft = 'family_left';

  // ============================================================
  // Settings Events
  // ============================================================

  /// Theme changed
  static const String eventThemeChanged = 'theme_changed';

  /// Language changed
  static const String eventLanguageChanged = 'language_changed';

  /// Currency changed
  static const String eventCurrencyChanged = 'currency_changed';

  /// Notifications toggled
  static const String eventNotificationsToggled = 'notifications_toggled';

  /// PIN enabled/disabled
  static const String eventPinToggled = 'pin_toggled';

  /// Biometric enabled/disabled
  static const String eventBiometricToggled = 'biometric_toggled';

  /// Data exported
  static const String eventDataExported = 'data_exported';

  /// Data backup created
  static const String eventDataBackup = 'data_backup';

  /// Data restored
  static const String eventDataRestored = 'data_restored';

  // ============================================================
  // Engagement Events
  // ============================================================

  /// Insight viewed
  static const String eventInsightViewed = 'insight_viewed';

  /// Report generated
  static const String eventReportGenerated = 'report_generated';

  /// Report shared
  static const String eventReportShared = 'report_shared';

  /// Search performed
  static const String eventSearchPerformed = 'search_performed';

  /// Filter applied
  static const String eventFilterApplied = 'filter_applied';

  /// Sort changed
  static const String eventSortChanged = 'sort_changed';

  /// App rated
  static const String eventAppRated = 'app_rated';

  /// Feedback submitted
  static const String eventFeedbackSubmitted = 'feedback_submitted';

  /// Help article viewed
  static const String eventHelpViewed = 'help_viewed';

  /// Tutorial completed
  static const String eventTutorialCompleted = 'tutorial_completed';

  // ============================================================
  // Error Events
  // ============================================================

  /// API error occurred
  static const String eventApiError = 'api_error';

  /// Sync failed
  static const String eventSyncFailed = 'sync_failed';

  /// Import failed
  static const String eventImportFailed = 'import_failed';

  /// Payment failed
  static const String eventPaymentFailed = 'payment_failed';

  // ============================================================
  // Event Parameters
  // ============================================================

  /// Transaction/budget/goal amount
  static const String paramAmount = 'amount';

  /// Currency code (INR, USD, etc.)
  static const String paramCurrency = 'currency';

  /// Category name or ID
  static const String paramCategory = 'category';

  /// Type (income, expense, transfer)
  static const String paramType = 'type';

  /// Transaction type (debit, credit)
  static const String paramTransactionType = 'transaction_type';

  /// Account name or ID
  static const String paramAccount = 'account';

  /// Account type (bank, cash, credit_card, etc.)
  static const String paramAccountType = 'account_type';

  /// Item ID (transaction, account, etc.)
  static const String paramItemId = 'item_id';

  /// Item name
  static const String paramItemName = 'item_name';

  /// Count of items
  static const String paramCount = 'count';

  /// Success/failure status
  static const String paramSuccess = 'success';

  /// Error message
  static const String paramError = 'error';

  /// Error code
  static const String paramErrorCode = 'error_code';

  /// Import source (sms, pdf, email, aggregator)
  static const String paramSource = 'source';

  /// Method (google, apple, email, phone)
  static const String paramMethod = 'method';

  /// Plan type (monthly, yearly)
  static const String paramPlan = 'plan';

  /// Duration in days
  static const String paramDuration = 'duration';

  /// Percentage value
  static const String paramPercentage = 'percentage';

  /// Screen name
  static const String paramScreen = 'screen';

  /// Feature name
  static const String paramFeature = 'feature';

  /// Value (generic)
  static const String paramValue = 'value';

  /// Previous value (for changes)
  static const String paramPreviousValue = 'previous_value';

  /// New value (for changes)
  static const String paramNewValue = 'new_value';

  /// Filter type
  static const String paramFilterType = 'filter_type';

  /// Sort order
  static const String paramSortOrder = 'sort_order';

  /// Search query
  static const String paramQuery = 'query';

  /// Date range type
  static const String paramDateRange = 'date_range';

  /// Start date
  static const String paramStartDate = 'start_date';

  /// End date
  static const String paramEndDate = 'end_date';

  /// Time spent in milliseconds
  static const String paramTimeSpent = 'time_spent';

  /// User ID (hashed)
  static const String paramUserId = 'user_id';

  /// Session ID
  static const String paramSessionId = 'session_id';

  /// App version
  static const String paramAppVersion = 'app_version';

  /// Platform (android, ios)
  static const String paramPlatform = 'platform';

  /// Device model
  static const String paramDeviceModel = 'device_model';

  /// OS version
  static const String paramOsVersion = 'os_version';


  // ============================================================
  // Social Auth Events
  // ============================================================
  /// Google social login initiated
  static const String eventSocialLoginGoogle = "social_login_google";

  /// Apple social login initiated
  static const String eventSocialLoginApple = "social_login_apple";

  /// Facebook social login initiated
  static const String eventSocialLoginFacebook = "social_login_facebook";

  /// Social login successful
  static const String eventSocialLoginSuccess = "social_login_success";

  /// Social login failed
  static const String eventSocialLoginFailed = "social_login_failed";

  // ============================================================
  // Delete Account Events
  // ============================================================
  /// Delete account flow started
  static const String eventDeleteAccountStarted = "delete_account_started";

  /// Delete account confirmed by user
  static const String eventDeleteAccountConfirmed = "delete_account_confirmed";

  /// Delete account completed successfully
  static const String eventDeleteAccountCompleted = "delete_account_completed";

  /// Delete account cancelled by user
  static const String eventDeleteAccountCancelled = "delete_account_cancelled";

  // ============================================================
  // Support Events
  // ============================================================
  /// Support screen viewed
  static const String eventSupportScreenViewed = "support_screen_viewed";

  /// Support ticket created
  static const String eventSupportTicketCreated = "support_ticket_created";

  /// FAQ viewed
  static const String eventSupportFaqViewed = "support_faq_viewed";

  /// Contact support tapped
  static const String eventSupportContactTapped = "support_contact_tapped";

  // ============================================================
  // User Properties
  // ============================================================

  /// User subscription status
  static const String userPropertySubscriptionStatus = 'subscription_status';

  /// User subscription plan
  static const String userPropertySubscriptionPlan = 'subscription_plan';

  /// Total accounts count
  static const String userPropertyAccountsCount = 'accounts_count';

  /// Total transactions count
  static const String userPropertyTransactionsCount = 'transactions_count';

  /// Primary currency
  static const String userPropertyCurrency = 'primary_currency';

  /// App language
  static const String userPropertyLanguage = 'app_language';

  /// App theme
  static const String userPropertyTheme = 'app_theme';

  /// Has PIN enabled
  static const String userPropertyHasPin = 'has_pin';

  /// Has biometric enabled
  static const String userPropertyHasBiometric = 'has_biometric';

  /// Is family member
  static const String userPropertyIsFamilyMember = 'is_family_member';

  /// Days since install
  static const String userPropertyDaysSinceInstall = 'days_since_install';

  /// User signup date
  static const String userPropertySignupDate = 'signup_date';

  /// Last active date
  static const String userPropertyLastActive = 'last_active';
}
