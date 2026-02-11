import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import 'receipt_scanner_sheet.dart';
import 'voice_input_sheet.dart';

/// Quick Add FAB with expandable options
class QuickAddFab extends ConsumerStatefulWidget {
  const QuickAddFab({
    super.key,
    this.onManualTap,
    this.onVoiceTap,
    this.onReceiptTap,
  });

  final VoidCallback? onManualTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onReceiptTap;

  @override
  ConsumerState<QuickAddFab> createState() => _QuickAddFabState();
}

class _QuickAddFabState extends ConsumerState<QuickAddFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _close() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
      _animationController.reverse();
    }
  }

  void _onManualTap() {
    _close();
    if (widget.onManualTap != null) {
      widget.onManualTap!();
    } else {
      context.go(AppRoutes.addTransaction);
    }
  }

  void _onVoiceTap() {
    _close();
    if (widget.onVoiceTap != null) {
      widget.onVoiceTap!();
    } else {
      _showVoiceInputSheet();
    }
  }

  void _onReceiptTap() {
    _close();
    if (widget.onReceiptTap != null) {
      widget.onReceiptTap!();
    } else {
      _showReceiptScannerSheet();
    }
  }

  void _showVoiceInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: VoiceInputSheet(
          onTransactionParsed: (request) {
            if (request != null) {
              _navigateToAddTransactionWithData(request);
            }
          },
        ),
      ),
    );
  }

  void _showReceiptScannerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ReceiptScannerSheet(
          onReceiptScanned: (request) {
            if (request != null) {
              _navigateToAddTransactionWithData(request);
            }
          },
        ),
      ),
    );
  }

  void _navigateToAddTransactionWithData(CreateTransactionRequest request) {
    // Navigate to add transaction screen with pre-filled data
    // The data can be passed via query parameters or a state management solution
    context.go(
      '${AppRoutes.addTransaction}?amount=${request.amount}&type=${request.type.value}${request.description != null ? '&description=${Uri.encodeComponent(request.description!)}' : ''}${request.payee != null ? '&payee=${Uri.encodeComponent(request.payee!)}' : ''}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop blur when expanded
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withValues(alpha: _fadeAnimation.value * 0.3),
                  );
                },
              ),
            ),
          ),

        // FAB Menu Items
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Receipt Option
            _buildFabOption(
              index: 2,
              icon: Iconsax.receipt,
              label: 'Scan Receipt',
              color: SpendexColors.warning,
              onTap: _onReceiptTap,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Voice Option
            _buildFabOption(
              index: 1,
              icon: Iconsax.microphone,
              label: 'Voice Input',
              color: SpendexColors.transfer,
              onTap: _onVoiceTap,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Manual Option
            _buildFabOption(
              index: 0,
              icon: Iconsax.edit,
              label: 'Manual Entry',
              color: SpendexColors.income,
              onTap: _onManualTap,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Main FAB
            _buildMainFab(isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    // Calculate delay based on index for staggered animation
    final delayedAnimation = CurvedAnimation(
      parent: _expandAnimation,
      curve: Interval(
        index * 0.1,
        0.6 + index * 0.1,
        curve: Curves.easeOutBack,
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        final scale = delayedAnimation.value;
        final translateY = (1 - scale) * 20;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.centerRight,
            child: Opacity(
              opacity: scale.clamp(0.0, 1.0),
              child: child,
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? SpendexColors.darkSurface
                  : SpendexColors.lightSurface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Mini FAB
          Material(
            color: color,
            elevation: 4,
            shadowColor: color.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFab(bool isDark) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value * math.pi * 2,
          child: child,
        );
      },
      child: FloatingActionButton(
        onPressed: _toggle,
        backgroundColor: SpendexColors.primary,
        elevation: 6,
        child: AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const Icon(Iconsax.add, size: 28),
              secondChild: const Icon(Icons.close, size: 28),
            );
          },
        ),
      ),
    );
  }
}

/// Quick Add Bottom Sheet (alternative implementation)
class QuickAddBottomSheet extends ConsumerStatefulWidget {
  const QuickAddBottomSheet({super.key});

  @override
  ConsumerState<QuickAddBottomSheet> createState() =>
      _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> {
  void _onManualTap() {
    Navigator.pop(context);
    context.go(AppRoutes.addTransaction);
  }

  void _onVoiceTap() {
    Navigator.pop(context);
    _showVoiceInputSheet();
  }

  void _onReceiptTap() {
    Navigator.pop(context);
    _showReceiptScannerSheet();
  }

  void _showVoiceInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: VoiceInputSheet(
          onTransactionParsed: (request) {
            if (request != null) {
              _navigateToAddTransactionWithData(request);
            }
          },
        ),
      ),
    );
  }

  void _showReceiptScannerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ReceiptScannerSheet(
          onReceiptScanned: (request) {
            if (request != null) {
              _navigateToAddTransactionWithData(request);
            }
          },
        ),
      ),
    );
  }

  void _navigateToAddTransactionWithData(CreateTransactionRequest request) {
    context.go(
      '${AppRoutes.addTransaction}?amount=${request.amount}&type=${request.type.value}${request.description != null ? '&description=${Uri.encodeComponent(request.description!)}' : ''}${request.payee != null ? '&payee=${Uri.encodeComponent(request.payee!)}' : ''}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
            child: Text(
              'Add Transaction',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildOption(
                    isDark: isDark,
                    icon: Iconsax.edit,
                    label: 'Manual',
                    description: 'Enter details\nmanually',
                    color: SpendexColors.income,
                    onTap: _onManualTap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOption(
                    isDark: isDark,
                    icon: Iconsax.microphone,
                    label: 'Voice',
                    description: 'Speak your\ntransaction',
                    color: SpendexColors.transfer,
                    onTap: _onVoiceTap,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOption(
                    isDark: isDark,
                    icon: Iconsax.receipt,
                    label: 'Receipt',
                    description: 'Scan a\nreceipt',
                    color: SpendexColors.warning,
                    onTap: _onReceiptTap,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOption({
    required bool isDark,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: SpendexTheme.labelMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the quick add bottom sheet
void showQuickAddBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const QuickAddBottomSheet(),
  );
}
