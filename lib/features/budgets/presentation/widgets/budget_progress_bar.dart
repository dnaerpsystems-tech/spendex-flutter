import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Budget Progress Bar Widget
/// An animated progress bar with color coding based on percentage
class BudgetProgressBar extends StatefulWidget {
  final double percentage;
  final int alertThreshold;
  final double height;
  final bool showLabel;
  final bool showWarningIcon;
  final bool animate;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.alertThreshold = 80,
    this.height = 8,
    this.showLabel = false,
    this.showWarningIcon = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.borderRadius,
  });

  @override
  State<BudgetProgressBar> createState() => _BudgetProgressBarState();
}

class _BudgetProgressBarState extends State<BudgetProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage.clamp(0, 100) / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BudgetProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage.clamp(0, 100) / 100,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return SpendexColors.expense;
    if (percentage >= 80) return const Color(0xFFF97316);
    if (percentage >= 60) return SpendexColors.warning;
    return SpendexColors.income;
  }

  LinearGradient _getProgressGradient(double percentage) {
    final color = _getProgressColor(percentage);
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        color.withValues(alpha: 0.8),
        color,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);
    final isOverBudget = widget.percentage >= 100;
    final isWarning = widget.percentage >= widget.alertThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.showWarningIcon && isWarning) ...[
                    _PulsingIcon(
                      icon: isOverBudget ? Iconsax.danger : Iconsax.warning_2,
                      color: _getProgressColor(widget.percentage),
                      pulse: isOverBudget,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    isOverBudget ? 'Over Budget' : 'Spent',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${widget.percentage.toStringAsFixed(1)}%',
                style: SpendexTheme.labelMedium.copyWith(
                  color: _getProgressColor(widget.percentage),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Stack(
          children: [
            // Background
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
                borderRadius: borderRadius,
              ),
            ),
            // Progress
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: _animation.value.clamp(0.0, 1.0),
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: _getProgressGradient(widget.percentage),
                      borderRadius: borderRadius,
                      boxShadow: widget.percentage > 0
                          ? [
                              BoxShadow(
                                color: _getProgressColor(widget.percentage)
                                    .withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Pulsing Icon for over-budget indication
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool pulse;

  const _PulsingIcon({
    required this.icon,
    required this.color,
    this.pulse = false,
  });

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: widget.pulse ? _animation.value : 1.0,
          child: Icon(
            widget.icon,
            size: 14,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Circular Budget Progress Indicator
class BudgetCircularProgress extends StatefulWidget {
  final double percentage;
  final int alertThreshold;
  final double size;
  final double strokeWidth;
  final bool showLabel;
  final bool animate;
  final Duration animationDuration;
  final Widget? center;

  const BudgetCircularProgress({
    super.key,
    required this.percentage,
    this.alertThreshold = 80,
    this.size = 120,
    this.strokeWidth = 10,
    this.showLabel = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.center,
  });

  @override
  State<BudgetCircularProgress> createState() => _BudgetCircularProgressState();
}

class _BudgetCircularProgressState extends State<BudgetCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage.clamp(0, 100) / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BudgetCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percentage.clamp(0, 100) / 100,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 100) return SpendexColors.expense;
    if (percentage >= 80) return const Color(0xFFF97316);
    if (percentage >= 60) return SpendexColors.warning;
    return SpendexColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getProgressColor(widget.percentage);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: widget.strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Progress circle
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              );
            },
          ),
          // Center content
          if (widget.center != null)
            widget.center!
          else if (widget.showLabel)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final displayPercentage = (_animation.value * 100).toStringAsFixed(0);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$displayPercentage%',
                      style: SpendexTheme.displayLarge.copyWith(
                        fontSize: widget.size * 0.22,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'spent',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                        fontSize: widget.size * 0.1,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
