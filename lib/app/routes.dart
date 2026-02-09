import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/accounts/presentation/screens/accounts_screen.dart';
import '../features/accounts/presentation/screens/account_details_screen.dart';
import '../features/accounts/presentation/screens/add_account_screen.dart';
import '../features/transactions/presentation/screens/transactions_screen.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../features/transactions/presentation/screens/transaction_details_screen.dart';
import '../features/budgets/presentation/screens/budgets_screen.dart';
import '../features/budgets/presentation/screens/add_budget_screen.dart';
import '../features/goals/presentation/screens/goals_screen.dart';
import '../features/goals/presentation/screens/add_goal_screen.dart';
import '../features/loans/presentation/screens/loans_screen.dart';
import '../features/loans/presentation/screens/add_loan_screen.dart';
import '../features/investments/presentation/screens/investments_screen.dart';
import '../features/investments/presentation/screens/add_investment_screen.dart';
import '../features/insights/presentation/screens/insights_screen.dart';
import '../features/family/presentation/screens/family_screen.dart';
import '../features/subscription/presentation/screens/subscription_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../shared/widgets/main_scaffold.dart';
import '../shared/widgets/splash_screen.dart';
import '../shared/widgets/onboarding_screen.dart';

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
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}

/// Navigation keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation.startsWith('/reset-password') ||
          state.matchedLocation.startsWith('/otp-verification');
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

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
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
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
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AddTransactionScreen(),
                ),
              ),
              GoRoute(
                path: 'analytics',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: InsightsScreen(),
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
        builder: (context, state) => const AddAccountScreen(),
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

      // Budget Routes
      GoRoute(
        path: AppRoutes.budgets,
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addBudget,
        builder: (context, state) => const AddBudgetScreen(),
      ),

      // Goal Routes
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addGoal,
        builder: (context, state) => const AddGoalScreen(),
      ),

      // Loan Routes
      GoRoute(
        path: AppRoutes.loans,
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        path: AppRoutes.addLoan,
        builder: (context, state) => const AddLoanScreen(),
      ),

      // Investment Routes
      GoRoute(
        path: AppRoutes.investments,
        builder: (context, state) => const InvestmentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addInvestment,
        builder: (context, state) => const AddInvestmentScreen(),
      ),

      // Other Routes
      GoRoute(
        path: AppRoutes.insights,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: AppRoutes.family,
        builder: (context, state) => const FamilyScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
