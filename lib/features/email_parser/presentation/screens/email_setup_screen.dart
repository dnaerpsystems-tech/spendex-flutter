import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/email_account_model.dart';
import '../providers/email_parser_provider.dart';

/// Email setup screen for connecting a new email account
class EmailSetupScreen extends ConsumerStatefulWidget {
  const EmailSetupScreen({super.key});

  @override
  ConsumerState<EmailSetupScreen> createState() => _EmailSetupScreenState();
}

class _EmailSetupScreenState extends ConsumerState<EmailSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _imapServerController = TextEditingController();
  final _imapPortController = TextEditingController(text: '993');

  EmailProvider _selectedProvider = EmailProvider.gmail;
  bool _showPassword = false;
  bool _showAdvancedSettings = false;
  bool _isConnecting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _imapServerController.dispose();
    _imapPortController.dispose();
    super.dispose();
  }

  void _onProviderChanged(EmailProvider? provider) {
    if (provider == null) return;

    setState(() {
      _selectedProvider = provider;

      // Auto-fill IMAP settings
      final config = EmailAccountModel.getDefaultImapConfig(provider);
      _imapServerController.text = config['imapServer'] as String;
      _imapPortController.text = (config['imapPort'] as int).toString();
    });
  }

  void _onEmailChanged(String email) {
    if (email.contains('@')) {
      final detectedProvider = EmailAccountModel.detectProvider(email);
      if (detectedProvider != _selectedProvider) {
        _onProviderChanged(detectedProvider);
      }
    }
  }

  Future<void> _connectAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    // Clear any previous errors
    ref.read(emailParserProvider.notifier).clearError();

    final success = await ref.read(emailParserProvider.notifier).connectAccount(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          provider: _selectedProvider,
          imapServer: _showAdvancedSettings && _imapServerController.text.isNotEmpty
              ? _imapServerController.text.trim()
              : null,
          imapPort: _showAdvancedSettings && _imapPortController.text.isNotEmpty
              ? int.tryParse(_imapPortController.text)
              : null,
        );

    setState(() {
      _isConnecting = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email account connected successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(emailParserProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to connect email account'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  String? _validateImapServer(String? value) {
    if (!_showAdvancedSettings) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter IMAP server';
    }
    return null;
  }

  String? _validateImapPort(String? value) {
    if (!_showAdvancedSettings) return null;
    if (value == null || value.isEmpty) {
      return 'Please enter IMAP port';
    }

    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return 'Please enter a valid port (1-65535)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Connect Email Account'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SpendexColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use an app-specific password for better security. Never share your main email password.',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Email field
            Text(
              'Email Address',
              style: SpendexTheme.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@gmail.com',
                prefixIcon: const Icon(Iconsax.sms),
              ),
              validator: _validateEmail,
              onChanged: _onEmailChanged,
              enabled: !_isConnecting,
            ),
            const SizedBox(height: 20),

            // Password field
            Text(
              'App-Specific Password',
              style: SpendexTheme.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                hintText: 'Enter app-specific password',
                prefixIcon: const Icon(Iconsax.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Iconsax.eye_slash : Iconsax.eye,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              validator: _validatePassword,
              enabled: !_isConnecting,
            ),
            const SizedBox(height: 20),

            // Provider dropdown
            Text(
              'Email Provider',
              style: SpendexTheme.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<EmailProvider>(
              value: _selectedProvider,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.global),
              ),
              items: EmailProvider.values.map((provider) {
                String label;
                switch (provider) {
                  case EmailProvider.gmail:
                    label = 'Gmail';
                    break;
                  case EmailProvider.outlook:
                    label = 'Outlook / Hotmail';
                    break;
                  case EmailProvider.yahoo:
                    label = 'Yahoo Mail';
                    break;
                  case EmailProvider.icloud:
                    label = 'iCloud Mail';
                    break;
                  case EmailProvider.other:
                    label = 'Custom / Other';
                    break;
                }

                return DropdownMenuItem(
                  value: provider,
                  child: Text(label),
                );
              }).toList(),
              onChanged: _isConnecting ? null : _onProviderChanged,
            ),
            const SizedBox(height: 24),

            // Advanced settings toggle
            InkWell(
              onTap: () {
                setState(() {
                  _showAdvancedSettings = !_showAdvancedSettings;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _showAdvancedSettings
                          ? Iconsax.arrow_down_1
                          : Iconsax.arrow_right_3,
                      size: 20,
                      color: SpendexColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Advanced Settings',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: SpendexColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Advanced settings (collapsible)
            if (_showAdvancedSettings) ...[
              const SizedBox(height: 16),
              Text(
                'IMAP Server',
                style: SpendexTheme.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imapServerController,
                decoration: InputDecoration(
                  hintText: 'imap.gmail.com',
                  prefixIcon: const Icon(Iconsax.cloud_connection),
                ),
                validator: _validateImapServer,
                enabled: !_isConnecting,
              ),
              const SizedBox(height: 16),
              Text(
                'IMAP Port',
                style: SpendexTheme.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imapPortController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '993',
                  prefixIcon: const Icon(Iconsax.security),
                ),
                validator: _validateImapPort,
                enabled: !_isConnecting,
              ),
            ],
            const SizedBox(height: 32),

            // Help text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.shield_tick,
                        color: SpendexColors.income,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How to get app-specific password:',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HelpText(
                    provider: 'Gmail',
                    steps: [
                      'Go to Google Account settings',
                      'Security → 2-Step Verification',
                      'App passwords → Generate new',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HelpText(
                    provider: 'Outlook',
                    steps: [
                      'Go to Microsoft Account settings',
                      'Security → Advanced security options',
                      'App passwords → Create new',
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Connect button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _connectAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      SpendexColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isConnecting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Connecting...',
                            style: SpendexTheme.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Connect Account',
                            style: SpendexTheme.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  const _HelpText({
    required this.provider,
    required this.steps,
  });

  final String provider;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider,
          style: SpendexTheme.labelMedium.copyWith(
            color: SpendexColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
