import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: SpendexColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: SpendexTheme.headlineMedium.copyWith(
                          color: SpendexColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: SpendexTheme.headlineMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Features Section
            _buildSectionTitle(context, 'Features'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Iconsax.wallet_1,
              title: 'Accounts',
              onTap: () => context.push(AppRoutes.accounts),
            ),
            _SettingsTile(
              icon: Iconsax.percentage_circle,
              title: 'Budgets',
              onTap: () => context.push(AppRoutes.budgets),
            ),
            _SettingsTile(
              icon: Iconsax.flag,
              title: 'Goals',
              onTap: () => context.push(AppRoutes.goals),
            ),
            _SettingsTile(
              icon: Iconsax.home_2,
              title: 'Loans',
              onTap: () => context.push(AppRoutes.loans),
            ),
            _SettingsTile(
              icon: Iconsax.chart,
              title: 'Investments',
              onTap: () => context.push(AppRoutes.investments),
            ),
            _SettingsTile(
              icon: Iconsax.document_upload,
              title: 'Bank Import',
              subtitle: 'Import from PDF, SMS, AA',
              onTap: () => context.push(AppRoutes.bankImport),
            ),
            _SettingsTile(
              icon: Iconsax.people,
              title: 'Family',
              onTap: () => context.push(AppRoutes.family),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionTitle(context, 'Preferences'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: themeMode == ThemeMode.dark ? Iconsax.moon : Iconsax.sun_1,
              title: 'Dark Mode',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).setTheme(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
            ),
            _SettingsTile(
              icon: Iconsax.notification,
              title: 'Notifications',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Iconsax.finger_scan,
              title: 'Biometric Lock',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Iconsax.global,
              title: 'Language',
              subtitle: 'English',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Subscription Section
            _buildSectionTitle(context, 'Subscription'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: SpendexColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.crown,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade to Pro',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unlock all features',
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.subscription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SpendexColors.primary,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Upgrade'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionTitle(context, 'Support'),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Iconsax.message_question,
              title: 'Help & FAQ',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Iconsax.sms,
              title: 'Contact Support',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Iconsax.star,
              title: 'Rate App',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Iconsax.share,
              title: 'Share App',
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Logout
            _SettingsTile(
              icon: Iconsax.logout,
              title: 'Logout',
              textColor: SpendexColors.expense,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpendexColors.expense,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm ?? false) {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                }
              },
            ),

            const SizedBox(height: 32),

            // App Version
            Center(
              child: Text(
                'Spendex v1.0.0',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: SpendexTheme.labelMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.textColor,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = textColor ?? Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SpendexTheme.titleMedium.copyWith(color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Iconsax.arrow_right_3,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
