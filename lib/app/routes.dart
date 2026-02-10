import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

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
import '../features/settings/presentation/screens/settings_screen.dart';
import '../shared/widgets/main_scaffold.dart';
import '../shared/widgets/splash_screen.dart';
import '../shared/widgets/onboarding_screen.dart';
import 'theme.dart';
import '../features/budgets/presentation/screens/budgets_screen.dart';
import '../features/budgets/presentation/screens/add_budget_screen.dart';
import '../features/budgets/presentation/screens/budget_details_screen.dart';

/// Placeholder screen for features not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: SpendexColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: SpendexColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: SpendexColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.code,
                      size: 16,
                      color: SpendexColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: SpendexColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AddTransactionScreen(),
                ),
              ),
              GoRoute(
                path: 'analytics',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: _PlaceholderScreen(
                    title: 'Analytics',
                    icon: Iconsax.chart,
                    description: 'View detailed analytics and insights about your spending patterns and financial health.',
                  ),
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
        builder: (context, state) => _PlaceholderScreen(
          title: 'Transaction Details',
          icon: Iconsax.receipt_item,
          description: 'View and edit transaction details including category, notes, and attachments.',
        ),
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
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Savings Goals',
          icon: Iconsax.flag,
          description: 'Track your progress towards financial goals like vacations, emergency funds, or major purchases.',
        ),
      ),
      GoRoute(
        path: AppRoutes.addGoal,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Add Goal',
          icon: Iconsax.flag,
          description: 'Create a new savings goal with target amount and deadline.',
        ),
      ),

      // Loan Routes
      GoRoute(
        path: AppRoutes.loans,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Loans & EMIs',
          icon: Iconsax.receipt_item,
          description: 'Track your loans, view EMI schedules, and monitor outstanding balances.',
        ),
      ),
      GoRoute(
        path: AppRoutes.addLoan,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Add Loan',
          icon: Iconsax.receipt_add,
          description: 'Add a new loan with EMI calculation and payment reminders.',
        ),
      ),

      // Investment Routes
      GoRoute(
        path: AppRoutes.investments,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Investments',
          icon: Iconsax.chart_2,
          description: 'Track your investment portfolio including mutual funds, stocks, and other assets.',
        ),
      ),
      GoRoute(
        path: AppRoutes.addInvestment,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Add Investment',
          icon: Iconsax.chart_21,
          description: 'Add a new investment with purchase details and current valuation.',
        ),
      ),

      // Other Routes
      GoRoute(
        path: AppRoutes.insights,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'AI Insights',
          icon: Iconsax.lamp_charge,
          description: 'Get personalized financial insights and recommendations powered by AI.',
        ),
      ),
      GoRoute(
        path: AppRoutes.family,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Family',
          icon: Iconsax.people,
          description: 'Manage family members and share accounts for collaborative financial tracking.',
        ),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Subscription',
          icon: Iconsax.crown,
          description: 'Upgrade to Pro or Premium for unlimited features and AI insights.',
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Profile',
          icon: Iconsax.user,
          description: 'View and edit your profile information, preferences, and security settings.',
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const _PlaceholderScreen(
          title: 'Notifications',
          icon: Iconsax.notification,
          description: 'View all your notifications including budget alerts, bill reminders, and insights.',
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
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
