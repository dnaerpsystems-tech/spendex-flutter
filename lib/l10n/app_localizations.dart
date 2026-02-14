import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Spendex'**
  String get appName;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Smart Money Management'**
  String get appTagline;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcomeMessage(String name);

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Next button label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Skip button label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Dismiss button label
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Update button label
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Remove button label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// View button label
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// View all button label
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// See more button label
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// See less button label
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// Search button/placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter button label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Sort button label
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Clear button label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Clear all button label
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Apply button label
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Yes option
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No option
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Please wait text
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// Processing state text
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Warning title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Info title
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Empty list message
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyList;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// Session expired message
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpired;

  /// Unauthorized error message
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to perform this action.'**
  String get unauthorized;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// This week label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Last week label
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// This month label
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Last month label
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// This year label
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// Last year label
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// Custom option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Daily frequency
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly frequency
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly frequency
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Yearly frequency
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// All option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// None option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Required field error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required;

  /// Invalid email error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// Invalid phone error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get invalidAmount;

  /// Too short error
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get tooShort;

  /// Too long error
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get tooLong;

  /// Minimum length error
  ///
  /// In en, this message translates to:
  /// **'Minimum {count} characters required'**
  String minLength(int count);

  /// Maximum length error
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} characters allowed'**
  String maxLength(int count);

  /// Formatted currency amount
  ///
  /// In en, this message translates to:
  /// **'₹{amount}'**
  String amountFormatted(String amount);

  /// Login button/title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue managing your finances'**
  String get loginSubtitle;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailHint;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Confirm password label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password input hint
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Remember me checkbox
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Social login separator text
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Apple sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// Don't have account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Sign up button/link
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Register screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Start your journey to financial freedom'**
  String get registerSubtitle;

  /// Full name label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Full name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneNumberHint;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Terms agreement checkbox
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get agreeToTerms;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Verify email title
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// Verify phone title
  ///
  /// In en, this message translates to:
  /// **'Verify Phone'**
  String get verifyPhone;

  /// OTP verification title
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// OTP sent message
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification code to {destination}'**
  String otpSentTo(String destination);

  /// Enter OTP label
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// Resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// Resend OTP countdown
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String resendOtpIn(int seconds);

  /// Verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Invalid OTP error
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get invalidOtp;

  /// OTP expired error
  ///
  /// In en, this message translates to:
  /// **'OTP has expired. Please request a new one.'**
  String get otpExpired;

  /// Reset password title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset password subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive reset instructions'**
  String get resetPasswordSubtitle;

  /// Send reset link button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Reset link sent message
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get resetLinkSent;

  /// New password label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Create new password title
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// Password requirements header
  ///
  /// In en, this message translates to:
  /// **'Password must contain:'**
  String get passwordRequirements;

  /// Password min length requirement
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordMinLength;

  /// Password uppercase requirement
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get passwordUppercase;

  /// Password lowercase requirement
  ///
  /// In en, this message translates to:
  /// **'One lowercase letter'**
  String get passwordLowercase;

  /// Password number requirement
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get passwordNumber;

  /// Password special char requirement
  ///
  /// In en, this message translates to:
  /// **'One special character'**
  String get passwordSpecial;

  /// Passwords mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Password changed success message
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// Login failed error
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// Registration failed error
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// Account created success message
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Biometric login button
  ///
  /// In en, this message translates to:
  /// **'Login with Biometrics'**
  String get biometricLogin;

  /// Face ID option
  ///
  /// In en, this message translates to:
  /// **'Use Face ID'**
  String get useFaceId;

  /// Fingerprint option
  ///
  /// In en, this message translates to:
  /// **'Use Fingerprint'**
  String get useFingerprint;

  /// Biometric not available message
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available'**
  String get biometricNotAvailable;

  /// Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Total balance label
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// Income label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense label
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Expenses label (plural)
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Available balance label
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// Current balance label
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// Recent transactions section title
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Spending overview section title
  ///
  /// In en, this message translates to:
  /// **'Spending Overview'**
  String get spendingOverview;

  /// Income vs expense comparison title
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomeVsExpense;

  /// Monthly overview title
  ///
  /// In en, this message translates to:
  /// **'Monthly Overview'**
  String get monthlyOverview;

  /// Financial summary title
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// Cash flow label
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// Net worth label
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// Savings label
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// Savings rate label
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get savingsRate;

  /// Savings percentage message
  ///
  /// In en, this message translates to:
  /// **'You saved {percentage}% this month'**
  String youSaved(String percentage);

  /// Transactions title
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Single transaction label
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// Number of transactions with plural support
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transactions} =1{1 transaction} other{{count} transactions}}'**
  String transactionCount(int count);

  /// Add transaction button
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Edit transaction title
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// Delete transaction title
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// Delete transaction confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionConfirmation;

  /// Transaction deleted message
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeleted;

  /// Transaction saved message
  ///
  /// In en, this message translates to:
  /// **'Transaction saved successfully'**
  String get transactionSaved;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Amount input hint
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get amountHint;

  /// Category label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Select category hint
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Select date hint
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Select time hint
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// Note label
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// Note input hint
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get noteHint;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Description input hint
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get descriptionHint;

  /// Attach receipt button
  ///
  /// In en, this message translates to:
  /// **'Attach Receipt'**
  String get attachReceipt;

  /// Receipt label
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// Scan receipt button
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// Recurring label
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring;

  /// Recurring transaction label
  ///
  /// In en, this message translates to:
  /// **'Recurring Transaction'**
  String get recurringTransaction;

  /// Frequency label
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Start date label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// End date label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No end date option
  ///
  /// In en, this message translates to:
  /// **'No End Date'**
  String get noEndDate;

  /// Transfer label
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// From account label
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccount;

  /// To account label
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccount;

  /// Transfer funds title
  ///
  /// In en, this message translates to:
  /// **'Transfer Funds'**
  String get transferFunds;

  /// Transfer success message
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully'**
  String get transferSuccessful;

  /// Search transactions placeholder
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// Filter by category option
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// Filter by account option
  ///
  /// In en, this message translates to:
  /// **'Filter by Account'**
  String get filterByAccount;

  /// Filter by date option
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// Sort by date option
  ///
  /// In en, this message translates to:
  /// **'Sort by Date'**
  String get sortByDate;

  /// Sort by amount option
  ///
  /// In en, this message translates to:
  /// **'Sort by Amount'**
  String get sortByAmount;

  /// Ascending sort order
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// Descending sort order
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// Accounts title
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// Single account label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Add account button
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// Edit account title
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? All your data will be permanently deleted.'**
  String get deleteAccountConfirmation;

  /// Account deleted message
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted;

  /// Account saved message
  ///
  /// In en, this message translates to:
  /// **'Account saved successfully'**
  String get accountSaved;

  /// Account name label
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// Account name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter account name'**
  String get accountNameHint;

  /// Account type label
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// Select account type hint
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectAccountType;

  /// Initial balance label
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// Initial balance input hint
  ///
  /// In en, this message translates to:
  /// **'Enter initial balance'**
  String get initialBalanceHint;

  /// Cash account type
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Bank account type
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bankAccount;

  /// Savings account type
  ///
  /// In en, this message translates to:
  /// **'Savings Account'**
  String get savingsAccount;

  /// Credit card type
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// Debit card type
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get debitCard;

  /// Wallet account type
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Investment account type
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investment;

  /// Loan account type
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get loan;

  /// Other option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Currency label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Indian Rupee currency
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee (₹)'**
  String get inr;

  /// US Dollar currency
  ///
  /// In en, this message translates to:
  /// **'US Dollar (\$)'**
  String get usd;

  /// Include in total toggle
  ///
  /// In en, this message translates to:
  /// **'Include in Total Balance'**
  String get includeInTotal;

  /// Make default account toggle
  ///
  /// In en, this message translates to:
  /// **'Make Default Account'**
  String get makeDefault;

  /// Default account label
  ///
  /// In en, this message translates to:
  /// **'Default Account'**
  String get defaultAccount;

  /// Budgets title
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Single budget label
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Add budget button
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// Edit budget title
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// Delete budget title
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// Delete budget confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget?'**
  String get deleteBudgetConfirmation;

  /// Budget deleted message
  ///
  /// In en, this message translates to:
  /// **'Budget deleted successfully'**
  String get budgetDeleted;

  /// Budget saved message
  ///
  /// In en, this message translates to:
  /// **'Budget saved successfully'**
  String get budgetSaved;

  /// Budget name label
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get budgetName;

  /// Budget amount label
  ///
  /// In en, this message translates to:
  /// **'Budget Amount'**
  String get budgetAmount;

  /// Budget period label
  ///
  /// In en, this message translates to:
  /// **'Budget Period'**
  String get budgetPeriod;

  /// Spent label
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// Remaining label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Budget progress text
  ///
  /// In en, this message translates to:
  /// **'{spent} of {total} spent'**
  String budgetProgress(String spent, String total);

  /// Budget remaining text
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemaining(String amount);

  /// Budget exceeded label
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceeded;

  /// Over budget label
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// Under budget label
  ///
  /// In en, this message translates to:
  /// **'Under Budget'**
  String get underBudget;

  /// On track label
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// Budget alert message
  ///
  /// In en, this message translates to:
  /// **'You have spent {percentage}% of your {category} budget'**
  String budgetAlert(String percentage, String category);

  /// No budgets message
  ///
  /// In en, this message translates to:
  /// **'No budgets set up yet'**
  String get noBudgets;

  /// Create first budget prompt
  ///
  /// In en, this message translates to:
  /// **'Create your first budget to track spending'**
  String get createFirstBudget;

  /// Categories title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Manage categories title
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// Add category button
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// Edit category title
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// Delete category title
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// Delete category confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get deleteCategoryConfirmation;

  /// Category deleted message
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeleted;

  /// Category saved message
  ///
  /// In en, this message translates to:
  /// **'Category saved successfully'**
  String get categorySaved;

  /// Category name label
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// Category name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get categoryNameHint;

  /// Category icon label
  ///
  /// In en, this message translates to:
  /// **'Category Icon'**
  String get categoryIcon;

  /// Category color label
  ///
  /// In en, this message translates to:
  /// **'Category Color'**
  String get categoryColor;

  /// Income categories section
  ///
  /// In en, this message translates to:
  /// **'Income Categories'**
  String get incomeCategories;

  /// Expense categories section
  ///
  /// In en, this message translates to:
  /// **'Expense Categories'**
  String get expenseCategories;

  /// Salary category
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// Business category
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// Freelance category
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// Investments category
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investments;

  /// Rental category
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get rental;

  /// Gifts category
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get gifts;

  /// Refunds category
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refunds;

  /// Food category
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get food;

  /// Groceries category
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get groceries;

  /// Shopping category
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// Transportation category
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// Utilities category
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// Entertainment category
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// Healthcare category
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get healthcare;

  /// Education category
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// Personal care category
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get personalCare;

  /// Travel category
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// Bills category
  ///
  /// In en, this message translates to:
  /// **'Bills & Fees'**
  String get bills;

  /// Insurance category
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// Taxes category
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxes;

  /// Subscriptions category
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// Rent category
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// Goals title
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// Savings goals title
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// Add goal button
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// Edit goal title
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// Delete goal title
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// Delete goal confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal?'**
  String get deleteGoalConfirmation;

  /// Goal deleted message
  ///
  /// In en, this message translates to:
  /// **'Goal deleted successfully'**
  String get goalDeleted;

  /// Goal saved message
  ///
  /// In en, this message translates to:
  /// **'Goal saved successfully'**
  String get goalSaved;

  /// Goal name label
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// Goal name input hint
  ///
  /// In en, this message translates to:
  /// **'What are you saving for?'**
  String get goalNameHint;

  /// Target amount label
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// Current amount label
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// Target date label
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// Goal progress text
  ///
  /// In en, this message translates to:
  /// **'{percentage}% completed'**
  String goalProgress(String percentage);

  /// Add money button
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// Withdraw money button
  ///
  /// In en, this message translates to:
  /// **'Withdraw Money'**
  String get withdrawMoney;

  /// Goal achieved message
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved! 🎉'**
  String get goalAchieved;

  /// Days remaining text
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Due today} =1{1 day remaining} other{{count} days remaining}}'**
  String daysRemaining(int count);

  /// Suggested monthly contribution
  ///
  /// In en, this message translates to:
  /// **'Suggested monthly: {amount}'**
  String monthlyContribution(String amount);

  /// No goals message
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get noGoals;

  /// Create first goal prompt
  ///
  /// In en, this message translates to:
  /// **'Set your first savings goal'**
  String get createFirstGoal;

  /// Analytics title
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Reports title
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Insights title
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Spending by category chart title
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// Income by category chart title
  ///
  /// In en, this message translates to:
  /// **'Income by Category'**
  String get incomeByCategory;

  /// Trend analysis title
  ///
  /// In en, this message translates to:
  /// **'Trend Analysis'**
  String get trendAnalysis;

  /// Expense trend chart title
  ///
  /// In en, this message translates to:
  /// **'Expense Trend'**
  String get expenseTrend;

  /// Income trend chart title
  ///
  /// In en, this message translates to:
  /// **'Income Trend'**
  String get incomeTrend;

  /// Comparison title
  ///
  /// In en, this message translates to:
  /// **'Comparison'**
  String get comparison;

  /// Comparison with last month
  ///
  /// In en, this message translates to:
  /// **'vs Last Month'**
  String get vsLastMonth;

  /// Comparison with last year
  ///
  /// In en, this message translates to:
  /// **'vs Last Year'**
  String get vsLastYear;

  /// Average spending label
  ///
  /// In en, this message translates to:
  /// **'Average Spending'**
  String get averageSpending;

  /// Average income label
  ///
  /// In en, this message translates to:
  /// **'Average Income'**
  String get averageIncome;

  /// Highest spending label
  ///
  /// In en, this message translates to:
  /// **'Highest Spending'**
  String get highestSpending;

  /// Lowest spending label
  ///
  /// In en, this message translates to:
  /// **'Lowest Spending'**
  String get lowestSpending;

  /// Top categories section title
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// Export report button
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// Export to PDF option
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPdf;

  /// Export to Excel option
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// Export to CSV option
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportToCsv;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get exportSuccessful;

  /// Select date range prompt
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// From date label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// To date label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit profile title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Profile updated message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// Change photo button
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Remove photo button
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Gallery option
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Personal information section
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// Security settings section
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get securitySettings;

  /// Change password button
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Current password label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Enable biometric toggle
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login'**
  String get enableBiometric;

  /// Enable PIN lock toggle
  ///
  /// In en, this message translates to:
  /// **'Enable PIN Lock'**
  String get enablePinLock;

  /// Set PIN button
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get setPin;

  /// Change PIN button
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Enter PIN prompt
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// Confirm PIN prompt
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// PIN changed message
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully'**
  String get pinChanged;

  /// Invalid PIN error
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN'**
  String get invalidPin;

  /// Auto lock setting
  ///
  /// In en, this message translates to:
  /// **'Auto Lock'**
  String get autoLock;

  /// Auto lock timer setting
  ///
  /// In en, this message translates to:
  /// **'Auto lock after'**
  String get autoLockAfter;

  /// Immediately option
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// 1 minute option
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get after1Minute;

  /// 5 minutes option
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get after5Minutes;

  /// 15 minutes option
  ///
  /// In en, this message translates to:
  /// **'After 15 minutes'**
  String get after15Minutes;

  /// Never option
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Appearance section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Select language prompt
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language option
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// Language changed message
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// Notifications title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notification settings title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Push notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Email notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Transaction alerts toggle
  ///
  /// In en, this message translates to:
  /// **'Transaction Alerts'**
  String get transactionAlerts;

  /// Budget alerts toggle
  ///
  /// In en, this message translates to:
  /// **'Budget Alerts'**
  String get budgetAlerts;

  /// Goal reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Goal Reminders'**
  String get goalReminders;

  /// Bill reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Bill Reminders'**
  String get billReminders;

  /// Weekly report toggle
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// Monthly report toggle
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// Data and backup section
  ///
  /// In en, this message translates to:
  /// **'Data & Backup'**
  String get dataAndBackup;

  /// Backup data button
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// Restore data button
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// Last backup date
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String lastBackup(String date);

  /// Backup success message
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupSuccessful;

  /// Restore success message
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get restoreSuccessful;

  /// Export data button
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Import data button
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Delete all data button
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// Delete all data confirmation
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your data. This action cannot be undone.'**
  String get deleteAllDataConfirmation;

  /// Data deleted message
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted'**
  String get dataDeleted;

  /// Help and support section
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// FAQ title
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Contact support button
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Send feedback button
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Rate app button
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// Share app button
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// Version text
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Licenses section
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get licenses;

  /// Account deleted message
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeleted2;

  /// Subscription title
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// Current plan label
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// Free plan name
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// Basic plan name
  ///
  /// In en, this message translates to:
  /// **'Basic Plan'**
  String get basicPlan;

  /// Premium plan name
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// Family plan name
  ///
  /// In en, this message translates to:
  /// **'Family Plan'**
  String get familyPlan;

  /// Upgrade plan button
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// Choose plan title
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get choosePlan;

  /// Plan features section
  ///
  /// In en, this message translates to:
  /// **'Plan Features'**
  String get planFeatures;

  /// Per month suffix
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// Per year suffix
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// Monthly billing
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthly;

  /// Yearly billing
  ///
  /// In en, this message translates to:
  /// **'Billed yearly'**
  String get billedYearly;

  /// Save percentage text
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(String percent);

  /// Subscribe button
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// Subscription active status
  ///
  /// In en, this message translates to:
  /// **'Subscription Active'**
  String get subscriptionActive;

  /// Subscription expiry date
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String subscriptionExpires(String date);

  /// Cancel subscription button
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get cancelSubscription;

  /// Cancel subscription confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your subscription?'**
  String get cancelSubscriptionConfirmation;

  /// Subscription cancelled message
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled'**
  String get subscriptionCancelled;

  /// Renew subscription button
  ///
  /// In en, this message translates to:
  /// **'Renew Subscription'**
  String get renewSubscription;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Add payment method button
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// Payment success message
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// Payment failed message
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// Invoice history section
  ///
  /// In en, this message translates to:
  /// **'Invoice History'**
  String get invoiceHistory;

  /// Download invoice button
  ///
  /// In en, this message translates to:
  /// **'Download Invoice'**
  String get downloadInvoice;

  /// Unlimited transactions feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited transactions'**
  String get unlimitedTransactions;

  /// Unlimited accounts feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited accounts'**
  String get unlimitedAccounts;

  /// Unlimited budgets feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited budgets'**
  String get unlimitedBudgets;

  /// Advanced analytics feature
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics'**
  String get advancedAnalytics;

  /// Priority support feature
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get prioritySupport;

  /// Cloud backup feature
  ///
  /// In en, this message translates to:
  /// **'Cloud backup'**
  String get cloudBackup;

  /// Multi-device sync feature
  ///
  /// In en, this message translates to:
  /// **'Multi-device sync'**
  String get multiDeviceSync;

  /// Ad-free feature
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get adFree;

  /// Family title
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// Family members section
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembers;

  /// Invite member button
  ///
  /// In en, this message translates to:
  /// **'Invite Member'**
  String get inviteMember;

  /// Invite by email option
  ///
  /// In en, this message translates to:
  /// **'Invite by Email'**
  String get inviteByEmail;

  /// Invite by link option
  ///
  /// In en, this message translates to:
  /// **'Invite by Link'**
  String get inviteByLink;

  /// Copy invite link button
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Link'**
  String get copyInviteLink;

  /// Link copied message
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// Invitation sent message
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get invitationSent;

  /// Pending invitations section
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// Member role label
  ///
  /// In en, this message translates to:
  /// **'Member Role'**
  String get memberRole;

  /// Owner role
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// Admin role
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Member role
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Viewer role
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get viewer;

  /// Remove member button
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// Remove member confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this member?'**
  String get removeMemberConfirmation;

  /// Member removed message
  ///
  /// In en, this message translates to:
  /// **'Member removed successfully'**
  String get memberRemoved;

  /// Leave family button
  ///
  /// In en, this message translates to:
  /// **'Leave Family'**
  String get leaveFamily;

  /// Leave family confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this family?'**
  String get leaveFamilyConfirmation;

  /// Family activity section
  ///
  /// In en, this message translates to:
  /// **'Family Activity'**
  String get familyActivity;

  /// Shared expenses label
  ///
  /// In en, this message translates to:
  /// **'Shared Expenses'**
  String get sharedExpenses;

  /// Family budget label
  ///
  /// In en, this message translates to:
  /// **'Family Budget'**
  String get familyBudget;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline mode label
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// Offline status message
  ///
  /// In en, this message translates to:
  /// **'You are currently offline'**
  String get youAreOffline;

  /// Offline changes message
  ///
  /// In en, this message translates to:
  /// **'Changes will be synced when online'**
  String get offlineChanges;

  /// Sync now button
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Syncing status
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Sync complete message
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncComplete;

  /// Sync failed message
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Please try again.'**
  String get syncFailed;

  /// Last synced time
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String lastSynced(String time);

  /// Pending changes count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pending change} other{{count} pending changes}}'**
  String pendingChanges(int count);

  /// Conflict detected title
  ///
  /// In en, this message translates to:
  /// **'Conflict Detected'**
  String get conflictDetected;

  /// Keep local version option
  ///
  /// In en, this message translates to:
  /// **'Keep Local Version'**
  String get keepLocal;

  /// Keep server version option
  ///
  /// In en, this message translates to:
  /// **'Keep Server Version'**
  String get keepServer;

  /// Merge both option
  ///
  /// In en, this message translates to:
  /// **'Merge Both'**
  String get mergeBoth;

  /// Bank import title
  ///
  /// In en, this message translates to:
  /// **'Bank Import'**
  String get bankImport;

  /// Import from bank button
  ///
  /// In en, this message translates to:
  /// **'Import from Bank'**
  String get importFromBank;

  /// Import from SMS button
  ///
  /// In en, this message translates to:
  /// **'Import from SMS'**
  String get importFromSms;

  /// Import from email button
  ///
  /// In en, this message translates to:
  /// **'Import from Email'**
  String get importFromEmail;

  /// Import success message
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get importSuccessful;

  /// Transactions imported count
  ///
  /// In en, this message translates to:
  /// **'{count} transactions imported'**
  String transactionsImported(int count);

  /// Duplicate detected title
  ///
  /// In en, this message translates to:
  /// **'Duplicate Detected'**
  String get duplicateDetected;

  /// Possible duplicate message
  ///
  /// In en, this message translates to:
  /// **'This transaction may be a duplicate'**
  String get possibleDuplicate;

  /// Keep both option
  ///
  /// In en, this message translates to:
  /// **'Keep Both'**
  String get keepBoth;

  /// Skip duplicate option
  ///
  /// In en, this message translates to:
  /// **'Skip Duplicate'**
  String get skipDuplicate;

  /// Loans title
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// Add loan button
  ///
  /// In en, this message translates to:
  /// **'Add Loan'**
  String get addLoan;

  /// Loan details title
  ///
  /// In en, this message translates to:
  /// **'Loan Details'**
  String get loanDetails;

  /// Loan amount label
  ///
  /// In en, this message translates to:
  /// **'Loan Amount'**
  String get loanAmount;

  /// Interest rate label
  ///
  /// In en, this message translates to:
  /// **'Interest Rate'**
  String get interestRate;

  /// EMI label
  ///
  /// In en, this message translates to:
  /// **'EMI'**
  String get emi;

  /// Tenure label
  ///
  /// In en, this message translates to:
  /// **'Tenure'**
  String get tenure;

  /// Remaining amount label
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// Paid amount label
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// Next payment label
  ///
  /// In en, this message translates to:
  /// **'Next Payment'**
  String get nextPayment;

  /// Payment schedule section
  ///
  /// In en, this message translates to:
  /// **'Payment Schedule'**
  String get paymentSchedule;

  /// Voice input button
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// Speak now prompt
  ///
  /// In en, this message translates to:
  /// **'Speak now...'**
  String get speakNow;

  /// Listening failed message
  ///
  /// In en, this message translates to:
  /// **'Could not understand. Please try again.'**
  String get listeningFailed;

  /// Permission required title
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// Camera permission message
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan receipts'**
  String get cameraPermission;

  /// Microphone permission message
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice input'**
  String get microphonePermission;

  /// Storage permission message
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to save files'**
  String get storagePermission;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Onboarding screen 1 title
  ///
  /// In en, this message translates to:
  /// **'Track Your Expenses'**
  String get onboardingTitle1;

  /// Onboarding screen 1 description
  ///
  /// In en, this message translates to:
  /// **'Easily track all your income and expenses in one place'**
  String get onboardingDesc1;

  /// Onboarding screen 2 title
  ///
  /// In en, this message translates to:
  /// **'Set Budgets & Goals'**
  String get onboardingTitle2;

  /// Onboarding screen 2 description
  ///
  /// In en, this message translates to:
  /// **'Create budgets and savings goals to achieve financial freedom'**
  String get onboardingDesc2;

  /// Onboarding screen 3 title
  ///
  /// In en, this message translates to:
  /// **'Get Insights'**
  String get onboardingTitle3;

  /// Onboarding screen 3 description
  ///
  /// In en, this message translates to:
  /// **'Understand your spending patterns with detailed analytics'**
  String get onboardingDesc3;

  /// Congratulations message
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Setup complete message
  ///
  /// In en, this message translates to:
  /// **'Your setup is complete'**
  String get setupComplete;

  /// Start tracking button
  ///
  /// In en, this message translates to:
  /// **'Start Tracking'**
  String get startTracking;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
