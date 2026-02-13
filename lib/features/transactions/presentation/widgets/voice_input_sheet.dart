
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';
import '../providers/voice_input_provider.dart';

/// Voice Input Sheet for speaking transactions
class VoiceInputSheet extends ConsumerStatefulWidget {
  const VoiceInputSheet({
    required this.onTransactionParsed, super.key,
  });

  final ValueChanged<CreateTransactionRequest?> onTransactionParsed;

  @override
  ConsumerState<VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends ConsumerState<VoiceInputSheet>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
  }

  void _onMicTap() {
    final voiceState = ref.read(voiceInputProvider);

    if (voiceState.state == VoiceInputState.listening) {
      _stopAnimations();
      ref.read(voiceInputProvider.notifier).stopListening();
    } else if (voiceState.state == VoiceInputState.idle ||
        voiceState.state == VoiceInputState.error ||
        voiceState.state == VoiceInputState.parsed) {
      _startAnimations();
      ref.read(voiceInputProvider.notifier).startListening();
    }
  }

  void _onExampleTap(String example) {
    _startAnimations();
    ref.read(voiceInputProvider.notifier).simulateVoiceInput(example);
  }

  void _onConfirm() {
    final voiceState = ref.read(voiceInputProvider);
    widget.onTransactionParsed(voiceState.parsedRequest);
    ref.read(voiceInputProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  void _onCancel() {
    ref.read(voiceInputProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final voiceState = ref.watch(voiceInputProvider);

    // Update animations based on state
    if (voiceState.state == VoiceInputState.listening) {
      if (!_pulseController.isAnimating) {
        _startAnimations();
      }
    } else {
      if (_pulseController.isAnimating) {
        _stopAnimations();
      }
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? SpendexColors.darkBorder
                  : SpendexColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SpendexColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.microphone,
                    color: SpendexColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Input',
                        style: SpendexTheme.headlineMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Speak your transaction',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _onCancel,
                  icon: const Icon(Iconsax.close_circle),
                ),
              ],
            ),
          ),

          // Microphone Button with Animations
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _buildMicrophoneButton(isDark, voiceState),
          ),

          // Status Text
          _buildStatusText(isDark, voiceState),

          // Recognized Text Display
          if (voiceState.recognizedText.isNotEmpty)
            _buildRecognizedTextDisplay(isDark, voiceState),

          // Parsed Transaction Preview
          if (voiceState.state == VoiceInputState.parsed &&
              voiceState.parsedRequest != null)
            _buildParsedPreview(isDark, voiceState),

          // Error Message
          if (voiceState.state == VoiceInputState.error)
            _buildErrorMessage(isDark, voiceState),

          // Example Commands
          if (voiceState.state == VoiceInputState.idle)
            _buildExampleCommands(isDark),

          // Action Buttons
          if (voiceState.state == VoiceInputState.parsed)
            _buildActionButtons(isDark),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMicrophoneButton(bool isDark, VoiceInputData voiceState) {
    final isListening = voiceState.state == VoiceInputState.listening;
    final isProcessing = voiceState.state == VoiceInputState.processing;

    return GestureDetector(
      onTap: isProcessing ? null : _onMicTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _waveAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer waves
              if (isListening) ...[
                for (int i = 0; i < 3; i++)
                  AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      final progress = (_waveAnimation.value + i * 0.33) % 1.0;
                      return Container(
                        width: 100 + (progress * 60),
                        height: 100 + (progress * 60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: SpendexColors.primary
                                .withValues(alpha: (1 - progress) * 0.3),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
              ],

              // Main button
              Transform.scale(
                scale: isListening ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: isListening
                        ? SpendexColors.primaryGradient
                        : null,
                    color: isListening
                        ? null
                        : (isDark
                            ? SpendexColors.darkCard
                            : SpendexColors.lightCard),
                    shape: BoxShape.circle,
                    border: isListening
                        ? null
                        : Border.all(
                            color: SpendexColors.primary,
                            width: 2,
                          ),
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color:
                                  SpendexColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isProcessing
                        ? const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            isListening ? Iconsax.microphone5 : Iconsax.microphone,
                            size: 40,
                            color: isListening
                                ? Colors.white
                                : SpendexColors.primary,
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusText(bool isDark, VoiceInputData voiceState) {
    String statusText;
    Color statusColor;

    switch (voiceState.state) {
      case VoiceInputState.idle:
        statusText = 'Tap the microphone to start';
        statusColor = isDark
            ? SpendexColors.darkTextSecondary
            : SpendexColors.lightTextSecondary;
        break;
      case VoiceInputState.listening:
        statusText = 'Listening... Tap to stop';
        statusColor = SpendexColors.primary;
        break;
      case VoiceInputState.processing:
        statusText = 'Processing...';
        statusColor = SpendexColors.primary;
        break;
      case VoiceInputState.parsed:
        statusText = 'Transaction recognized!';
        statusColor = SpendexColors.income;
        break;
      case VoiceInputState.error:
        statusText = 'Try again';
        statusColor = SpendexColors.expense;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        statusText,
        style: SpendexTheme.titleMedium.copyWith(color: statusColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRecognizedTextDisplay(bool isDark, VoiceInputData voiceState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? SpendexColors.darkBackground
            : SpendexColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.quote_up,
            size: 20,
            color: SpendexColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              voiceState.recognizedText,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (voiceState.state == VoiceInputState.listening)
            const _BlinkingCursor(),
        ],
      ),
    );
  }

  Widget _buildParsedPreview(bool isDark, VoiceInputData voiceState) {
    final request = voiceState.parsedRequest!;
    final typeColor = _getTypeColor(request.type);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(request.type),
                      size: 16,
                      color: typeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      request.type.label,
                      style: SpendexTheme.labelMedium.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _currencyFormat.format(request.amount / 100),
                style: SpendexTheme.displayLarge.copyWith(
                  color: typeColor,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Details
          if (voiceState.parsedCategory != null)
            _buildDetailRow(
              isDark,
              Iconsax.category,
              'Category',
              voiceState.parsedCategory!,
            ),
          if (voiceState.parsedDescription != null &&
              voiceState.parsedDescription!.isNotEmpty)
            _buildDetailRow(
              isDark,
              Iconsax.document_text,
              'Description',
              voiceState.parsedDescription!,
            ),
          if (request.payee != null)
            _buildDetailRow(
              isDark,
              Iconsax.user,
              'Payee',
              request.payee!,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      bool isDark, IconData icon, String label, String value,) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(bool isDark, VoiceInputData voiceState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpendexColors.expense.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpendexColors.expense.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.warning_2,
            color: SpendexColors.expense,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              voiceState.errorMessage ?? 'An error occurred',
              style: SpendexTheme.bodyMedium.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCommands(bool isDark) {
    final examples = ref.read(voiceInputProvider.notifier).getExampleCommands();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Try saying:',
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: examples.take(4).map((example) {
              return InkWell(
                onTap: () => _onExampleTap(example),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? SpendexColors.darkBackground
                        : SpendexColors.lightBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? SpendexColors.darkBorder
                          : SpendexColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    '"$example"',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextPrimary
                          : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ref.read(voiceInputProvider.notifier).reset();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _onConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.tick_circle, size: 20),
                  SizedBox(width: 8),
                  Text('Add Transaction'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return SpendexColors.income;
      case TransactionType.expense:
        return SpendexColors.expense;
      case TransactionType.transfer:
        return SpendexColors.transfer;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Iconsax.arrow_down;
      case TransactionType.expense:
        return Iconsax.arrow_up;
      case TransactionType.transfer:
        return Iconsax.arrow_swap_horizontal;
    }
  }
}

/// Blinking cursor widget for text input effect
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Container(
            width: 2,
            height: 20,
            color: SpendexColors.primary,
          ),
        );
      },
    );
  }
}
