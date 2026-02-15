import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../core/firebase/analytics_service.dart';
import '../core/utils/app_logger.dart';
import '../features/accounts/presentation/screens/account_details_screen.dart';
import '../features/accounts/presentation/screens/accounts_screen.dart';
import '../features/accounts/presentation/screens/add_account_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/bank_import/data/models/parsed_transaction_model.dart';
import '../features/bank_import/presentation/screens/account_aggregator_screen.dart';
import '../features/bank_import/presentation/screens/bank_import_home_screen.dart';
import '../features/bank_import/presentation/screens/import_history_screen.dart';
import '../features/bank_import/presentation/screens/import_preview_screen.dart';
import '../features/bank_import/presentation/screens/pdf_import_screen.dart';
import '../features/bank_import/presentation/screens/sms_parser_screen.dart';
import '../features/budgets/presentation/screens/add_budget_screen.dart';
import '../features/budgets/presentation/screens/budget_details_screen.dart';
import '../features/budgets/presentation/screens/budgets_screen.dart';
import '../features/categories/presentation/screens/add_category_screen.dart';
import '../features/categories/presentation/screens/categories_screen.dart';
import '../features/categories/presentation/screens/category_details_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/duplicate_detection/presentation/screens/duplicate_resolution_screen.dart';
import '../features/email_parser/presentation/screens/email_details_screen.dart';
import '../features/email_parser/presentation/screens/email_filters_screen.dart';
import '../features/email_parser/presentation/screens/email_parser_screen.dart';
import '../features/email_parser/presentation/screens/email_setup_screen.dart';
import '../features/family/presentation/screens/family_screen.dart';
import '../features/goals/presentation/screens/add_goal_screen.dart';
import '../features/goals/presentation/screens/goal_details_screen.dart';
import '../features/goals/presentation/screens/goals_screen.dart';
import '../features/insights/presentation/screens/insight_detail_screen.dart';
import '../features/insights/presentation/screens/insights_screen.dart';
import '../features/investments/presentation/screens/add_investment_screen.dart';
import '../features/investments/presentation/screens/holdings_screen.dart';
import '../features/investments/presentation/screens/investment_details_screen.dart';
import '../features/investments/presentation/screens/portfolio_dashboard_screen.dart';
import '../features/investments/presentation/screens/tax_savings_screen.dart';
import '../features/loans/presentation/screens/add_loan_screen.dart';
import '../features/loans/presentation/screens/loan_details_screen.dart';
import '../features/loans/presentation/screens/loans_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/settings/presentation/screens/change_password_screen.dart';
import '../features/settings/presentation/screens/device_management_screen.dart';
import '../features/settings/presentation/screens/edit_profile_screen.dart';
import '../features/settings/presentation/screens/pin_entry_screen.dart';
import '../features/settings/presentation/screens/preferences_screen.dart';
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/security_settings_screen.dart';
import '../features/settings/presentation/screens/set_pin_screen.dart';
import '../features/settings/presentation/screens/delete_account_screen.dart';
import '../features/settings/presentation/screens/linked_accounts_screen.dart';
import '../features/settings/presentation/screens/account_recovery_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/support/presentation/screens/support_screen.dart';
import '../features/support/presentation/screens/create_ticket_screen.dart';
import '../features/support/presentation/screens/ticket_list_screen.dart';
import '../features/support/presentation/screens/ticket_detail_screen.dart';
import '../features/support/data/models/ticket_model.dart';
import '../features/subscription/presentation/screens/screens.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/screens/transaction_details_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../shared/widgets/main_scaffold.dart';
import '../shared/widgets/onboarding_screen.dart';
import '../shared/widgets/splash_screen.dart';
import 'theme.dart';

/// Route names
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main routes
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String transactions = '/home/transactions';
  static const String addTransaction = '/home/add-transaction';
  static const String analytics = '/home/analytics';
  static const String more = '/home/more';

  // Account routes
  static const String accounts = '/accounts';
  static const String accountDetails = '/accounts/:id';
  static const String addAccount = '/accounts/add';

  // Category routes
  static const String categories = '/categories';
  static const String addCategory = '/categories/add';
  static const String categoryDetails = '/categories/:id';

  // Transaction routes
  static const String transactionDetails = '/transactions/:id';

  // Budget routes
  static const String budgets = '/budgets';
  static const String addBudget = '/budgets/add';
  static const String budgetDetails = '/budgets/:id';

  // Goal routes
  static const String goals = '/goals';
  static const String addGoal = '/goals/add';
  static const String goalDetails = '/goals/:id';

  // Loan routes
  static const String loans = '/loans';
  static const String addLoan = '/loans/add';
  static const String loanDetails = '/loans/:id';

  // Investment routes
  static const String investments = '/investments';
  static const String addInvestment = '/investments/add';
  static const String investmentDetails = '/investments/:id';

  // Other routes
  static const String insights = '/insights';
  static const String family = '/family';
  static const String subscription = '/subscription';
  static const String subscriptionPlans = '/subscription/plans';
  static const String subscriptionCheckout = '/subscription/checkout';
  static const String subscriptionUpi = '/subscription/upi';
  static const String subscriptionInvoices = '/subscription/invoices';
  static const String settings = '/settings';
  static const String deleteAccount = '/delete-account';
  static const String linkedAccounts = '/settings/linked-accounts';
  static const String accountRecovery = '/settings/account-recovery';
  static const String support = '/support';
  static const String createTicket = '/support/create-ticket';
  static const String ticketList = '/support/tickets';
  static const String ticketDetail = '/support/tickets';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Bank Import routes
  static const String bankImport = '/bank-import';
  static const String pdfImport = '/bank-import/pdf-import';
  static const String smsParser = '/bank-import/sms-parser';
  static const String accountAggregator = '/bank-import/account-aggregator';
  static const String importPreview = '/bank-import/preview/:importId';
  static const String importHistory = '/bank-import/history';
  static const String duplicateResolution = '/bank-import/duplicate-resolution';

  // Email Parser routes
  static const String emailParser = '/email-parser';
  static const String emailSetup = '/email-parser/setup';
  static const String emailFilters = '/email-parser/filters';
  static const String emailDetails = '/email-parser/details/:emailId';
}

/// Navigation keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Auth state notifier for router refresh
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref _ref;
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthChangeNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    observers: [AnalyticsService.observer],
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      if (kDebugMode) {
        AppLogger.d('Router redirect: ${state.matchedLocation}');
      }
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation.startsWith('/reset-password') ||
          state.matchedLocation.startsWith('/otp-verification');
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (kDebugMode) {
        AppLogger.d(
            'Router: isOnSplash=$isOnSplash, isOnOnboarding=$isOnOnboarding, isAuth=$isAuthenticated',);
      }

      // Allow splash and onboarding without redirection
      if (isOnSplash || isOnOnboarding) {
        return null;
      }

      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isOnAuthRoute) {
        return AppRoutes.login;
      }

      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isOnAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final purpose = state.uri.queryParameters['purpose'] ?? 'verification';
          return OtpVerificationScreen(email: email, purpose: purpose);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(email: email, token: token);
        },
      ),

      // Main Shell Route with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            redirect: (context, state) {
              if (state.matchedLocation == AppRoutes.home) {
                return AppRoutes.dashboard;
              }
              return null;
            },
            routes: [
              GoRoute(
                path: 'dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
              GoRoute(
                path: 'transactions',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TransactionsScreen(),
                ),
              ),
              GoRoute(
                path: 'add-transaction',
                pageBuilder: (context, state) {
                  final transactionId = state.uri.queryParameters['id'];
                  return NoTransitionPage(
                    child: AddTransactionScreen(transactionId: transactionId),
                  );
                },
              ),
              GoRoute(
                path: 'analytics',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AnalyticsScreen(),
                ),
              ),
              GoRoute(
                path: 'more',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Account Routes
      GoRoute(
        path: AppRoutes.accounts,
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAccount,
        builder: (context, state) {
          final accountId = state.uri.queryParameters['id'];
          return AddAccountScreen(accountId: accountId);
        },
      ),
      GoRoute(
        path: AppRoutes.accountDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AccountDetailsScreen(accountId: id);
        },
      ),

      // Transaction Routes
      GoRoute(
        path: AppRoutes.transactionDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TransactionDetailsScreen(transactionId: id);
        },
      ),

      // Category Routes
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCategory,
        builder: (context, state) => const AddCategoryScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.categoryDetails}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CategoryDetailsScreen(categoryId: id);
        },
      ),

      // Budget Routes
      GoRoute(
        path: AppRoutes.budgets,
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/budgets/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BudgetDetailsScreen(budgetId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.addBudget,
        builder: (context, state) {
          final budgetId = state.uri.queryParameters['id'];
          return AddBudgetScreen(budgetId: budgetId);
        },
      ),

      // Goal Routes
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/goals/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return GoalDetailsScreen(goalId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.addGoal,
        builder: (context, state) {
          final goalId = state.uri.queryParameters['id'];
          return AddGoalScreen(goalId: goalId);
        },
      ),

      // Loan Routes
      GoRoute(
        path: AppRoutes.loans,
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        path: '/loans/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return LoanDetailsScreen(loanId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.addLoan,
        builder: (context, state) {
          final loanId = state.uri.queryParameters['id'];
          return AddLoanScreen(loanId: loanId);
        },
      ),

      // Investment Routes
      GoRoute(
        path: AppRoutes.investments,
        builder: (context, state) => const PortfolioDashboardScreen(),
      ),
      GoRoute(
        path: '/investments/holdings',
        builder: (context, state) => const HoldingsScreen(),
      ),
      GoRoute(
        path: '/investments/tax',
        builder: (context, state) => const TaxSavingsScreen(),
      ),
      GoRoute(
        path: '/investments/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return InvestmentDetailsScreen(investmentId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.addInvestment,
        builder: (context, state) {
          final investmentId = state.uri.queryParameters['id'];
          return AddInvestmentScreen(investmentId: investmentId);
        },
      ),

      // Insights Routes
      GoRoute(
        path: AppRoutes.insights,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/insights/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return InsightDetailScreen(insightId: id);
        },
      ),

      // Other Routes
      GoRoute(
        path: AppRoutes.family,
        builder: (context, state) => const FamilyScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionPlans,
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionCheckout,
        builder: (context, state) {
          return const CheckoutScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.subscriptionUpi,
        builder: (context, state) {
          return const UpiPaymentScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.subscriptionInvoices,
        builder: (context, state) => const InvoicesScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Profile & Security Routes
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // Delete Account Route
      GoRoute(
        path: AppRoutes.deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      // Linked Accounts Route
      GoRoute(
        path: AppRoutes.linkedAccounts,
        builder: (context, state) => const LinkedAccountsScreen(),
      ),
      // Account Recovery Route
      GoRoute(
        path: AppRoutes.accountRecovery,
        builder: (context, state) => const AccountRecoveryScreen(),
      ),
      // Support Route
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportScreen(),
      ),
      // Create Ticket Route
      GoRoute(
        path: AppRoutes.createTicket,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final category = extra?['category'] as TicketCategory?;
          return CreateTicketScreen(initialCategory: category);
        },
      ),
      // Ticket List Route
      GoRoute(
        path: AppRoutes.ticketList,
        builder: (context, state) => const TicketListScreen(),
      ),
      // Ticket Detail Route
      GoRoute(
        path: '${AppRoutes.ticketDetail}/:ticketId',
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId'] ?? '';
          return TicketDetailScreen(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/preferences',
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: '/security/set-pin',
        builder: (context, state) => const SetPinScreen(),
      ),
      GoRoute(
        path: '/security/pin-entry',
        builder: (context, state) => const PinEntryScreen(),
      ),
      GoRoute(
        path: '/security/devices',
        builder: (context, state) => const DeviceManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Bank Import Routes
      GoRoute(
        path: AppRoutes.bankImport,
        builder: (context, state) => const BankImportHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.pdfImport,
        builder: (context, state) => const PdfImportScreen(),
      ),
      GoRoute(
        path: AppRoutes.smsParser,
        builder: (context, state) => const SmsParserScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountAggregator,
        builder: (context, state) => const AccountAggregatorScreen(),
      ),
      GoRoute(
        path: AppRoutes.importPreview,
        builder: (context, state) {
          final importId = state.pathParameters['importId'] ?? '';
          return ImportPreviewScreen(importId: importId);
        },
      ),
      GoRoute(
        path: AppRoutes.importHistory,
        builder: (context, state) => const ImportHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.duplicateResolution,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Missing required data')),
            );
          }
          return DuplicateResolutionScreen(
            importId: extra['importId'] as String,
            transactions: (extra['transactions'] as List<dynamic>).cast<ParsedTransactionModel>(),
          );
        },
      ),

      // Email Parser Routes
      GoRoute(
        path: AppRoutes.emailParser,
        builder: (context, state) => const EmailParserScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailSetup,
        builder: (context, state) => const EmailSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailFilters,
        builder: (context, state) => const EmailFiltersScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailDetails,
        builder: (context, state) {
          final emailId = state.pathParameters['emailId'] ?? '';
          return EmailDetailsScreen(emailId: emailId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.warning_2,
              size: 64,
              color: SpendexColors.expense,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpendexColors.lightTextSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Iconsax.home),
              label: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
