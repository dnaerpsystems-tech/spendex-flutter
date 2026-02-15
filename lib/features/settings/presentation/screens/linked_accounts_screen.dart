import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/theme.dart';
import '../../../../core/services/social_auth_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Screen for managing linked social accounts (Google, Apple, Facebook).
/// Allows users to link/unlink their social accounts for easier sign-in.
class LinkedAccountsScreen extends ConsumerStatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  ConsumerState<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends ConsumerState<LinkedAccountsScreen> {
  bool _isLinkingGoogle = false;
  bool _isLinkingApple = false;
  bool _isLinkingFacebook = false;

  // Track linked accounts - in real app, this would come from backend
  bool _isGoogleLinked = false;
  bool _isAppleLinked = false;
  bool _isFacebookLinked = false;

  final _socialAuthService = SocialAuthService();

  @override
  void initState() {
    super.initState();
    _loadLinkedAccounts();
  }

  @override
  void dispose() {
    _socialAuthService.dispose();
    super.dispose();
  }

  Future<void> _loadLinkedAccounts() async {
    // Load from user profile or backend
    final user = ref.read(currentUserProvider);
    if (user != null) {
      setState(() {
        _isGoogleLinked = false; // TODO: Implement when backend supports social linking
        _isAppleLinked = false; // TODO: Implement when backend supports social linking
        _isFacebookLinked = false; // TODO: Implement when backend supports social linking
      });
    }
  }

  Future<void> _linkGoogle() async {
    setState(() => _isLinkingGoogle = true);
    try {
      final result = await _socialAuthService.signInWithGoogle();
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: SpendexColors.expense),
          );
        },
        (credential) async {
          // Send to backend to link account
          // await ref.read(authStateProvider.notifier).linkSocialAccount('google', credential.accessToken);
          setState(() => _isGoogleLinked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google account linked successfully'), backgroundColor: SpendexColors.income),
          );
        },
      );
    } finally {
      setState(() => _isLinkingGoogle = false);
    }
  }

  Future<void> _unlinkGoogle() async {
    final confirm = await _showUnlinkConfirmation('Google');
    if (confirm != true) return;

    setState(() => _isLinkingGoogle = true);
    try {
      // await ref.read(authStateProvider.notifier).unlinkSocialAccount('google');
      setState(() => _isGoogleLinked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google account unlinked'), backgroundColor: SpendexColors.income),
      );
    } finally {
      setState(() => _isLinkingGoogle = false);
    }
  }

  Future<void> _linkApple() async {
    setState(() => _isLinkingApple = true);
    try {
      final result = await _socialAuthService.signInWithApple();
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: SpendexColors.expense),
          );
        },
        (credential) async {
          setState(() => _isAppleLinked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Apple account linked successfully'), backgroundColor: SpendexColors.income),
          );
        },
      );
    } finally {
      setState(() => _isLinkingApple = false);
    }
  }

  Future<void> _unlinkApple() async {
    final confirm = await _showUnlinkConfirmation('Apple');
    if (confirm != true) return;

    setState(() => _isLinkingApple = true);
    try {
      setState(() => _isAppleLinked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple account unlinked'), backgroundColor: SpendexColors.income),
      );
    } finally {
      setState(() => _isLinkingApple = false);
    }
  }

  Future<void> _linkFacebook() async {
    setState(() => _isLinkingFacebook = true);
    try {
      final result = await _socialAuthService.signInWithFacebook();
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message), backgroundColor: SpendexColors.expense),
          );
        },
        (credential) async {
          setState(() => _isFacebookLinked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facebook account linked successfully'), backgroundColor: SpendexColors.income),
          );
        },
      );
    } finally {
      setState(() => _isLinkingFacebook = false);
    }
  }

  Future<void> _unlinkFacebook() async {
    final confirm = await _showUnlinkConfirmation('Facebook');
    if (confirm != true) return;

    setState(() => _isLinkingFacebook = true);
    try {
      setState(() => _isFacebookLinked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facebook account unlinked'), backgroundColor: SpendexColors.income),
      );
    } finally {
      setState(() => _isLinkingFacebook = false);
    }
  }

  Future<bool?> _showUnlinkConfirmation(String provider) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlink $provider?'),
        content: Text('You will no longer be able to sign in with your $provider account. You can link it again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: SpendexColors.expense),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Linked Accounts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Connect your social accounts for easier sign-in',
            style: SpendexTheme.bodyMedium.copyWith(
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),

          // Google
          _AccountTile(
            icon: Iconsax.user,
            title: 'Google',
            isLinked: _isGoogleLinked,
            isLoading: _isLinkingGoogle,
            onLink: _linkGoogle,
            onUnlink: _unlinkGoogle,
          ),
          const SizedBox(height: 12),

          // Apple
          _AccountTile(
            icon: Iconsax.user,
            title: 'Apple',
            isLinked: _isAppleLinked,
            isLoading: _isLinkingApple,
            onLink: _linkApple,
            onUnlink: _unlinkApple,
          ),
          const SizedBox(height: 12),

          // Facebook
          _AccountTile(
            icon: Iconsax.user,
            title: 'Facebook',
            isLinked: _isFacebookLinked,
            isLoading: _isLinkingFacebook,
            onLink: _linkFacebook,
            onUnlink: _unlinkFacebook,
          ),

          const SizedBox(height: 32),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? SpendexColors.darkCard
                  : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: SpendexColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You must keep at least one sign-in method active (email/password or a linked account).',
                    style: SpendexTheme.bodySmall.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLinked;
  final bool isLoading;
  final VoidCallback onLink;
  final VoidCallback onUnlink;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.isLinked,
    required this.isLoading,
    required this.onLink,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final borderColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLinked
              ? SpendexColors.income.withValues(alpha: 0.5)
              : borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? SpendexColors.darkSurface
                  : SpendexColors.lightSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: textColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SpendexTheme.titleMedium.copyWith(color: textColor),
                ),
                Text(
                  isLinked ? 'Connected' : 'Not connected',
                  style: SpendexTheme.bodySmall.copyWith(
                    color: isLinked ? SpendexColors.income : secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: isLinked ? onUnlink : onLink,
              style: TextButton.styleFrom(
                foregroundColor: isLinked ? SpendexColors.expense : SpendexColors.primary,
              ),
              child: Text(isLinked ? 'Unlink' : 'Link'),
            ),
        ],
      ),
    );
  }
}
