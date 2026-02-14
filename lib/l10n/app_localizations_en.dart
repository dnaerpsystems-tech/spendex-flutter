// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Spendex';

  @override
  String get appTagline => 'Smart Money Management';

  @override
  String welcomeMessage(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get submit => 'Submit';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get add => 'Add';

  @override
  String get update => 'Update';

  @override
  String get remove => 'Remove';

  @override
  String get view => 'View';

  @override
  String get viewAll => 'View All';

  @override
  String get seeMore => 'See More';

  @override
  String get seeLess => 'See Less';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get clear => 'Clear';

  @override
  String get clearAll => 'Clear All';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get loading => 'Loading...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get processing => 'Processing...';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get noData => 'No data available';

  @override
  String get noResults => 'No results found';

  @override
  String get emptyList => 'Nothing here yet';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get sessionExpired => 'Session expired. Please login again.';

  @override
  String get unauthorized => 'You are not authorized to perform this action.';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get lastYear => 'Last Year';

  @override
  String get custom => 'Custom';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get required => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get invalidAmount => 'Please enter a valid amount';

  @override
  String get tooShort => 'Too short';

  @override
  String get tooLong => 'Too long';

  @override
  String minLength(int count) {
    return 'Minimum $count characters required';
  }

  @override
  String maxLength(int count) {
    return 'Maximum $count characters allowed';
  }

  @override
  String amountFormatted(String amount) {
    return '₹$amount';
  }

  @override
  String get login => 'Login';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue managing your finances';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email address';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get register => 'Register';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Start your journey to financial freedom';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => 'Enter your phone number';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get agreeToTerms =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get verifyPhone => 'Verify Phone';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String otpSentTo(String destination) {
    return 'We\'ve sent a verification code to $destination';
  }

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendOtpIn(int seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get verify => 'Verify';

  @override
  String get invalidOtp => 'Invalid OTP. Please try again.';

  @override
  String get otpExpired => 'OTP has expired. Please request a new one.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email to receive reset instructions';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Password reset link sent to your email';

  @override
  String get newPassword => 'New Password';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get passwordRequirements => 'Password must contain:';

  @override
  String get passwordMinLength => 'At least 8 characters';

  @override
  String get passwordUppercase => 'One uppercase letter';

  @override
  String get passwordLowercase => 'One lowercase letter';

  @override
  String get passwordNumber => 'One number';

  @override
  String get passwordSpecial => 'One special character';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get biometricLogin => 'Login with Biometrics';

  @override
  String get useFaceId => 'Use Face ID';

  @override
  String get useFingerprint => 'Use Fingerprint';

  @override
  String get biometricNotAvailable =>
      'Biometric authentication is not available';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get expenses => 'Expenses';

  @override
  String get balance => 'Balance';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get spendingOverview => 'Spending Overview';

  @override
  String get incomeVsExpense => 'Income vs Expense';

  @override
  String get monthlyOverview => 'Monthly Overview';

  @override
  String get financialSummary => 'Financial Summary';

  @override
  String get cashFlow => 'Cash Flow';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get savings => 'Savings';

  @override
  String get savingsRate => 'Savings Rate';

  @override
  String youSaved(String percentage) {
    return 'You saved $percentage% this month';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String get transaction => 'Transaction';

  @override
  String transactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
      zero: 'No transactions',
    );
    return '$_temp0';
  }

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirmation =>
      'Are you sure you want to delete this transaction?';

  @override
  String get transactionDeleted => 'Transaction deleted successfully';

  @override
  String get transactionSaved => 'Transaction saved successfully';

  @override
  String get amount => 'Amount';

  @override
  String get amountHint => 'Enter amount';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get date => 'Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get time => 'Time';

  @override
  String get selectTime => 'Select Time';

  @override
  String get note => 'Note';

  @override
  String get noteHint => 'Add a note (optional)';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'Enter description';

  @override
  String get attachReceipt => 'Attach Receipt';

  @override
  String get receipt => 'Receipt';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get recurring => 'Recurring';

  @override
  String get recurringTransaction => 'Recurring Transaction';

  @override
  String get frequency => 'Frequency';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get noEndDate => 'No End Date';

  @override
  String get transfer => 'Transfer';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get transferFunds => 'Transfer Funds';

  @override
  String get transferSuccessful => 'Transfer completed successfully';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get filterByCategory => 'Filter by Category';

  @override
  String get filterByAccount => 'Filter by Account';

  @override
  String get filterByDate => 'Filter by Date';

  @override
  String get sortByDate => 'Sort by Date';

  @override
  String get sortByAmount => 'Sort by Amount';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get accounts => 'Accounts';

  @override
  String get account => 'Account';

  @override
  String get addAccount => 'Add Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? All your data will be permanently deleted.';

  @override
  String get accountDeleted => 'Account deleted successfully';

  @override
  String get accountSaved => 'Account saved successfully';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountNameHint => 'Enter account name';

  @override
  String get accountType => 'Account Type';

  @override
  String get selectAccountType => 'Select Account Type';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get initialBalanceHint => 'Enter initial balance';

  @override
  String get cash => 'Cash';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get savingsAccount => 'Savings Account';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get debitCard => 'Debit Card';

  @override
  String get wallet => 'Wallet';

  @override
  String get investment => 'Investment';

  @override
  String get loan => 'Loan';

  @override
  String get other => 'Other';

  @override
  String get currency => 'Currency';

  @override
  String get inr => 'Indian Rupee (₹)';

  @override
  String get usd => 'US Dollar (\$)';

  @override
  String get includeInTotal => 'Include in Total Balance';

  @override
  String get makeDefault => 'Make Default Account';

  @override
  String get defaultAccount => 'Default Account';

  @override
  String get budgets => 'Budgets';

  @override
  String get budget => 'Budget';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get deleteBudgetConfirmation =>
      'Are you sure you want to delete this budget?';

  @override
  String get budgetDeleted => 'Budget deleted successfully';

  @override
  String get budgetSaved => 'Budget saved successfully';

  @override
  String get budgetName => 'Budget Name';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get budgetPeriod => 'Budget Period';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String budgetProgress(String spent, String total) {
    return '$spent of $total spent';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String get budgetExceeded => 'Budget Exceeded';

  @override
  String get overBudget => 'Over Budget';

  @override
  String get underBudget => 'Under Budget';

  @override
  String get onTrack => 'On Track';

  @override
  String budgetAlert(String percentage, String category) {
    return 'You have spent $percentage% of your $category budget';
  }

  @override
  String get noBudgets => 'No budgets set up yet';

  @override
  String get createFirstBudget => 'Create your first budget to track spending';

  @override
  String get categories => 'Categories';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String get deleteCategoryConfirmation =>
      'Are you sure you want to delete this category?';

  @override
  String get categoryDeleted => 'Category deleted successfully';

  @override
  String get categorySaved => 'Category saved successfully';

  @override
  String get categoryName => 'Category Name';

  @override
  String get categoryNameHint => 'Enter category name';

  @override
  String get categoryIcon => 'Category Icon';

  @override
  String get categoryColor => 'Category Color';

  @override
  String get incomeCategories => 'Income Categories';

  @override
  String get expenseCategories => 'Expense Categories';

  @override
  String get salary => 'Salary';

  @override
  String get business => 'Business';

  @override
  String get freelance => 'Freelance';

  @override
  String get investments => 'Investments';

  @override
  String get rental => 'Rental';

  @override
  String get gifts => 'Gifts';

  @override
  String get refunds => 'Refunds';

  @override
  String get food => 'Food & Dining';

  @override
  String get groceries => 'Groceries';

  @override
  String get shopping => 'Shopping';

  @override
  String get transportation => 'Transportation';

  @override
  String get utilities => 'Utilities';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get healthcare => 'Healthcare';

  @override
  String get education => 'Education';

  @override
  String get personalCare => 'Personal Care';

  @override
  String get travel => 'Travel';

  @override
  String get bills => 'Bills & Fees';

  @override
  String get insurance => 'Insurance';

  @override
  String get taxes => 'Taxes';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get rent => 'Rent';

  @override
  String get goals => 'Goals';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get deleteGoalConfirmation =>
      'Are you sure you want to delete this goal?';

  @override
  String get goalDeleted => 'Goal deleted successfully';

  @override
  String get goalSaved => 'Goal saved successfully';

  @override
  String get goalName => 'Goal Name';

  @override
  String get goalNameHint => 'What are you saving for?';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get currentAmount => 'Current Amount';

  @override
  String get targetDate => 'Target Date';

  @override
  String goalProgress(String percentage) {
    return '$percentage% completed';
  }

  @override
  String get addMoney => 'Add Money';

  @override
  String get withdrawMoney => 'Withdraw Money';

  @override
  String get goalAchieved => 'Goal Achieved! 🎉';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days remaining',
      one: '1 day remaining',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String monthlyContribution(String amount) {
    return 'Suggested monthly: $amount';
  }

  @override
  String get noGoals => 'No savings goals yet';

  @override
  String get createFirstGoal => 'Set your first savings goal';

  @override
  String get analytics => 'Analytics';

  @override
  String get reports => 'Reports';

  @override
  String get insights => 'Insights';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get incomeByCategory => 'Income by Category';

  @override
  String get trendAnalysis => 'Trend Analysis';

  @override
  String get expenseTrend => 'Expense Trend';

  @override
  String get incomeTrend => 'Income Trend';

  @override
  String get comparison => 'Comparison';

  @override
  String get vsLastMonth => 'vs Last Month';

  @override
  String get vsLastYear => 'vs Last Year';

  @override
  String get averageSpending => 'Average Spending';

  @override
  String get averageIncome => 'Average Income';

  @override
  String get highestSpending => 'Highest Spending';

  @override
  String get lowestSpending => 'Lowest Spending';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get exportReport => 'Export Report';

  @override
  String get exportToPdf => 'Export to PDF';

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get exportToCsv => 'Export to CSV';

  @override
  String get exportSuccessful => 'Report exported successfully';

  @override
  String get selectDateRange => 'Select Date Range';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get securitySettings => 'Security Settings';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get enableBiometric => 'Enable Biometric Login';

  @override
  String get enablePinLock => 'Enable PIN Lock';

  @override
  String get setPin => 'Set PIN';

  @override
  String get changePin => 'Change PIN';

  @override
  String get enterPin => 'Enter PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get pinChanged => 'PIN changed successfully';

  @override
  String get invalidPin => 'Invalid PIN';

  @override
  String get autoLock => 'Auto Lock';

  @override
  String get autoLockAfter => 'Auto lock after';

  @override
  String get immediately => 'Immediately';

  @override
  String get after1Minute => 'After 1 minute';

  @override
  String get after5Minutes => 'After 5 minutes';

  @override
  String get after15Minutes => 'After 15 minutes';

  @override
  String get never => 'Never';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get transactionAlerts => 'Transaction Alerts';

  @override
  String get budgetAlerts => 'Budget Alerts';

  @override
  String get goalReminders => 'Goal Reminders';

  @override
  String get billReminders => 'Bill Reminders';

  @override
  String get weeklyReport => 'Weekly Report';

  @override
  String get monthlyReport => 'Monthly Report';

  @override
  String get dataAndBackup => 'Data & Backup';

  @override
  String get backupData => 'Backup Data';

  @override
  String get restoreData => 'Restore Data';

  @override
  String lastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get backupSuccessful => 'Backup created successfully';

  @override
  String get restoreSuccessful => 'Data restored successfully';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteAllDataConfirmation =>
      'This will permanently delete all your data. This action cannot be undone.';

  @override
  String get dataDeleted => 'All data has been deleted';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get faq => 'FAQ';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get aboutApp => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get licenses => 'Open Source Licenses';

  @override
  String get accountDeleted2 => 'Account deleted successfully';

  @override
  String get subscription => 'Subscription';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get basicPlan => 'Basic Plan';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get familyPlan => 'Family Plan';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get choosePlan => 'Choose a Plan';

  @override
  String get planFeatures => 'Plan Features';

  @override
  String get perMonth => '/month';

  @override
  String get perYear => '/year';

  @override
  String get billedMonthly => 'Billed monthly';

  @override
  String get billedYearly => 'Billed yearly';

  @override
  String savePercent(String percent) {
    return 'Save $percent%';
  }

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscriptionActive => 'Subscription Active';

  @override
  String subscriptionExpires(String date) {
    return 'Expires on $date';
  }

  @override
  String get cancelSubscription => 'Cancel Subscription';

  @override
  String get cancelSubscriptionConfirmation =>
      'Are you sure you want to cancel your subscription?';

  @override
  String get subscriptionCancelled => 'Subscription cancelled';

  @override
  String get renewSubscription => 'Renew Subscription';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get addPaymentMethod => 'Add Payment Method';

  @override
  String get paymentSuccessful => 'Payment successful';

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get invoiceHistory => 'Invoice History';

  @override
  String get downloadInvoice => 'Download Invoice';

  @override
  String get unlimitedTransactions => 'Unlimited transactions';

  @override
  String get unlimitedAccounts => 'Unlimited accounts';

  @override
  String get unlimitedBudgets => 'Unlimited budgets';

  @override
  String get advancedAnalytics => 'Advanced analytics';

  @override
  String get prioritySupport => 'Priority support';

  @override
  String get cloudBackup => 'Cloud backup';

  @override
  String get multiDeviceSync => 'Multi-device sync';

  @override
  String get adFree => 'Ad-free experience';

  @override
  String get family => 'Family';

  @override
  String get familyMembers => 'Family Members';

  @override
  String get inviteMember => 'Invite Member';

  @override
  String get inviteByEmail => 'Invite by Email';

  @override
  String get inviteByLink => 'Invite by Link';

  @override
  String get copyInviteLink => 'Copy Invite Link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get invitationSent => 'Invitation sent successfully';

  @override
  String get pendingInvitations => 'Pending Invitations';

  @override
  String get memberRole => 'Member Role';

  @override
  String get owner => 'Owner';

  @override
  String get admin => 'Admin';

  @override
  String get member => 'Member';

  @override
  String get viewer => 'Viewer';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get removeMemberConfirmation =>
      'Are you sure you want to remove this member?';

  @override
  String get memberRemoved => 'Member removed successfully';

  @override
  String get leaveFamily => 'Leave Family';

  @override
  String get leaveFamilyConfirmation =>
      'Are you sure you want to leave this family?';

  @override
  String get familyActivity => 'Family Activity';

  @override
  String get sharedExpenses => 'Shared Expenses';

  @override
  String get familyBudget => 'Family Budget';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get youAreOffline => 'You are currently offline';

  @override
  String get offlineChanges => 'Changes will be synced when online';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncComplete => 'Sync complete';

  @override
  String get syncFailed => 'Sync failed. Please try again.';

  @override
  String lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending changes',
      one: '1 pending change',
    );
    return '$_temp0';
  }

  @override
  String get conflictDetected => 'Conflict Detected';

  @override
  String get keepLocal => 'Keep Local Version';

  @override
  String get keepServer => 'Keep Server Version';

  @override
  String get mergeBoth => 'Merge Both';

  @override
  String get bankImport => 'Bank Import';

  @override
  String get importFromBank => 'Import from Bank';

  @override
  String get importFromSms => 'Import from SMS';

  @override
  String get importFromEmail => 'Import from Email';

  @override
  String get importSuccessful => 'Import successful';

  @override
  String transactionsImported(int count) {
    return '$count transactions imported';
  }

  @override
  String get duplicateDetected => 'Duplicate Detected';

  @override
  String get possibleDuplicate => 'This transaction may be a duplicate';

  @override
  String get keepBoth => 'Keep Both';

  @override
  String get skipDuplicate => 'Skip Duplicate';

  @override
  String get loans => 'Loans';

  @override
  String get addLoan => 'Add Loan';

  @override
  String get loanDetails => 'Loan Details';

  @override
  String get loanAmount => 'Loan Amount';

  @override
  String get interestRate => 'Interest Rate';

  @override
  String get emi => 'EMI';

  @override
  String get tenure => 'Tenure';

  @override
  String get remainingAmount => 'Remaining Amount';

  @override
  String get paidAmount => 'Paid Amount';

  @override
  String get nextPayment => 'Next Payment';

  @override
  String get paymentSchedule => 'Payment Schedule';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get speakNow => 'Speak now...';

  @override
  String get listeningFailed => 'Could not understand. Please try again.';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get cameraPermission =>
      'Camera permission is required to scan receipts';

  @override
  String get microphonePermission =>
      'Microphone permission is required for voice input';

  @override
  String get storagePermission =>
      'Storage permission is required to save files';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingTitle1 => 'Track Your Expenses';

  @override
  String get onboardingDesc1 =>
      'Easily track all your income and expenses in one place';

  @override
  String get onboardingTitle2 => 'Set Budgets & Goals';

  @override
  String get onboardingDesc2 =>
      'Create budgets and savings goals to achieve financial freedom';

  @override
  String get onboardingTitle3 => 'Get Insights';

  @override
  String get onboardingDesc3 =>
      'Understand your spending patterns with detailed analytics';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get setupComplete => 'Your setup is complete';

  @override
  String get startTracking => 'Start Tracking';
}
