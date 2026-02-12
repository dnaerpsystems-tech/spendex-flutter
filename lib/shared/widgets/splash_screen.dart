import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../core/di/injection.dart';
import '../../core/storage/local_storage.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    debugPrint('Splash: Starting initialization...');
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) {
      debugPrint('Splash: Not mounted after delay');
      return;
    }

    debugPrint('Splash: Getting localStorage...');
    final localStorage = getIt<LocalStorageService>();
    debugPrint('Splash: Got localStorage');

    final authNotifier = ref.read(authStateProvider.notifier);
    debugPrint('Splash: Got authNotifier');

    // Check authentication status with timeout
    try {
      debugPrint('Splash: Checking auth status...');
      await authNotifier.checkAuthStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Splash: Auth check timed out');
        },
      );
      debugPrint('Splash: Auth check completed');
    } catch (e) {
      debugPrint('Splash: Auth check error: $e');
    }

    if (!mounted) {
      debugPrint('Splash: Not mounted after auth check');
      return;
    }

    final authState = ref.read(authStateProvider);
    debugPrint('Splash: Auth state - isAuthenticated: ${authState.isAuthenticated}');

    final isOnboardingCompleted = localStorage.isOnboardingCompleted();
    debugPrint('Splash: Onboarding completed: $isOnboardingCompleted');

    debugPrint('Splash: Navigating...');
    if (!isOnboardingCompleted) {
      debugPrint('Splash: Going to onboarding');
      context.go(AppRoutes.onboarding);
    } else if (authState.isAuthenticated) {
      debugPrint('Splash: Going to home');
      context.go(AppRoutes.home);
    } else {
      debugPrint('Splash: Going to login');
      context.go(AppRoutes.login);
    }
    debugPrint('Splash: Navigation called');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpendexColors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'S',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: SpendexColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Spendex',
                        style: SpendexTheme.displayLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart Finance Management',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
