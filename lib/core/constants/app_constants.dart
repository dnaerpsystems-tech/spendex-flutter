/// Application Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Spendex';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  static const String themeKey = 'theme';
  static const String onboardingKey = 'onboarding_completed';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String pinEnabledKey = 'pin_enabled';
  static const String pinKey = 'pin';
  static const String languageKey = 'language';
  static const String lastSyncKey = 'last_sync';

  // Token Expiry
  static const int accessTokenExpiryMinutes = 15;
  static const int refreshTokenExpiryDays = 7;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration sessionTimeout = Duration(minutes: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Limits
  static const int maxTransactionAmount = 99999999; // 9,99,99,999 paise = ₹99,99,999
  static const int maxNoteLength = 500;
  static const int maxDescriptionLength = 200;
  static const int maxNameLength = 100;

  // Currency
  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₹';
  static const int currencyDecimals = 2;
  static const int paisePerRupee = 100;

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String timeFormat = 'hh:mm a';
  static const String monthYearFormat = 'MMM yyyy';
  static const String isoDateFormat = 'yyyy-MM-dd';

  // Biometric
  static const String biometricReason = 'Authenticate to access Spendex';

  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );
  static final RegExp pinRegex = RegExp(r'^\d{4,6}$');
  static final RegExp otpRegex = RegExp(r'^\d{6}$');

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Budget Periods
enum BudgetPeriod {
  weekly('WEEKLY', 'Weekly'),
  monthly('MONTHLY', 'Monthly'),
  quarterly('QUARTERLY', 'Quarterly'),
  yearly('YEARLY', 'Yearly');

  const BudgetPeriod(this.value, this.label);
  final String value;
  final String label;
}

/// Transaction Types
enum TransactionType {
  income('INCOME', 'Income'),
  expense('EXPENSE', 'Expense'),
  transfer('TRANSFER', 'Transfer');

  const TransactionType(this.value, this.label);
  final String value;
  final String label;
}

/// Account Types
enum AccountType {
  savings('SAVINGS', 'Savings'),
  current('CURRENT', 'Current'),
  creditCard('CREDIT_CARD', 'Credit Card'),
  cash('CASH', 'Cash'),
  wallet('WALLET', 'Wallet'),
  investment('INVESTMENT', 'Investment'),
  loan('LOAN', 'Loan'),
  other('OTHER', 'Other');

  const AccountType(this.value, this.label);
  final String value;
  final String label;
}

/// Loan Types
enum LoanType {
  home('HOME', 'Home Loan'),
  vehicle('VEHICLE', 'Vehicle Loan'),
  personal('PERSONAL', 'Personal Loan'),
  education('EDUCATION', 'Education Loan'),
  gold('GOLD', 'Gold Loan'),
  business('BUSINESS', 'Business Loan'),
  other('OTHER', 'Other');

  const LoanType(this.value, this.label);
  final String value;
  final String label;
}

/// Investment Types
enum InvestmentType {
  mutualFund('mutual_fund', 'Mutual Fund'),
  stock('stock', 'Stock'),
  fixedDeposit('fixed_deposit', 'Fixed Deposit'),
  recurringDeposit('recurring_deposit', 'Recurring Deposit'),
  ppf('ppf', 'PPF'),
  epf('epf', 'EPF'),
  nps('nps', 'NPS'),
  gold('gold', 'Gold'),
  realEstate('real_estate', 'Real Estate'),
  sukanyaSamriddhi('sukanya_samriddhi', 'Sukanya Samriddhi'),
  sovereignGoldBond('sovereign_gold_bond', 'Sovereign Gold Bond'),
  postOffice('post_office', 'Post Office'),
  crypto('crypto', 'Cryptocurrency'),
  other('other', 'Other');

  const InvestmentType(this.value, this.label);
  final String value;
  final String label;
}

/// Tax Sections
enum TaxSection {
  section80C('80C', 'Section 80C'),
  section80CCC('80CCC', 'Section 80CCC'),
  section80CCD('80CCD', 'Section 80CCD'),
  section80D('80D', 'Section 80D'),
  section80E('80E', 'Section 80E'),
  section80G('80G', 'Section 80G'),
  section80TTA('80TTA', 'Section 80TTA'),
  section80TTB('80TTB', 'Section 80TTB'),
  none('none', 'None');

  const TaxSection(this.value, this.label);
  final String value;
  final String label;
}

/// User Roles
enum UserRole {
  owner('OWNER', 'Owner'),
  admin('ADMIN', 'Admin'),
  member('MEMBER', 'Member'),
  viewer('VIEWER', 'Viewer');

  const UserRole(this.value, this.label);
  final String value;
  final String label;
}

/// User Status
enum UserStatus {
  active('ACTIVE', 'Active'),
  suspended('SUSPENDED', 'Suspended'),
  deleted('DELETED', 'Deleted'),
  pendingVerification('PENDING_VERIFICATION', 'Pending Verification');

  const UserStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Subscription Status
enum SubscriptionStatus {
  trialing('TRIALING', 'Trial'),
  active('ACTIVE', 'Active'),
  pastDue('PAST_DUE', 'Past Due'),
  cancelled('CANCELLED', 'Cancelled'),
  expired('EXPIRED', 'Expired'),
  paused('PAUSED', 'Paused');

  const SubscriptionStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Billing Cycle
enum BillingCycle {
  monthly('MONTHLY', 'Monthly'),
  quarterly('QUARTERLY', 'Quarterly'),
  halfYearly('HALF_YEARLY', 'Half Yearly'),
  yearly('YEARLY', 'Yearly');

  const BillingCycle(this.value, this.label);
  final String value;
  final String label;
}

/// Goal Status
enum GoalStatus {
  active('ACTIVE', 'Active'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled');

  const GoalStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Loan Status
enum LoanStatus {
  active('ACTIVE', 'Active'),
  closed('CLOSED', 'Closed'),
  defaulted('DEFAULTED', 'Defaulted');

  const LoanStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Category Type
enum CategoryType {
  income('INCOME', 'Income'),
  expense('EXPENSE', 'Expense');

  const CategoryType(this.value, this.label);
  final String value;
  final String label;
}

/// Insight Types
enum InsightType {
  spendingAlert('spending_alert', 'Spending Alert'),
  budgetWarning('budget_warning', 'Budget Warning'),
  savingsOpportunity('savings_opportunity', 'Savings Opportunity'),
  investmentSuggestion('investment_suggestion', 'Investment Suggestion'),
  billReminder('bill_reminder', 'Bill Reminder'),
  goalMilestone('goal_milestone', 'Goal Milestone'),
  unusualActivity('unusual_activity', 'Unusual Activity'),
  monthlySummary('monthly_summary', 'Monthly Summary');

  const InsightType(this.value, this.label);
  final String value;
  final String label;
}

/// Insight Priority
enum InsightPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const InsightPriority(this.value, this.label);
  final String value;
  final String label;
}

/// Notification Types
enum NotificationType {
  transaction('transaction', 'Transaction'),
  budget('budget', 'Budget'),
  goal('goal', 'Goal'),
  loan('loan', 'Loan'),
  investment('investment', 'Investment'),
  subscription('subscription', 'Subscription'),
  family('family', 'Family'),
  system('system', 'System');

  const NotificationType(this.value, this.label);
  final String value;
  final String label;
}
