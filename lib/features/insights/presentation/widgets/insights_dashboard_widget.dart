import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/insight_model.dart';
import 'insight_card.dart';

class InsightsDashboardWidget extends ConsumerStatefulWidget {
  const InsightsDashboardWidget({
    required this.insights,
    super.key,
    this.isLoading = false,
    this.error,
    this.onViewAllTap,
    this.onInsightTap,
    this.onDismiss,
  });
  final List<InsightModel> insights;
  final bool isLoading;
  final String? error;
  final VoidCallback? onViewAllTap;
  final Function(InsightModel)? onInsightTap;
  final Function(String)? onDismiss;

  @override
  ConsumerState<InsightsDashboardWidget> createState() => _InsightsDashboardWidgetState();
}

class _InsightsDashboardWidgetState extends ConsumerState<InsightsDashboardWidget> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool _userInteracted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (widget.insights.isEmpty || widget.isLoading) {
      return;
    }

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_userInteracted) {
        return;
      }

      if (_currentPage < widget.insights.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onUserScroll() {
    setState(() {
      _userInteracted = true;
    });
    // Resume auto-scroll after 10 seconds of no interaction
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        _userInteracted = false;
      });
      _startAutoScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.lamp_charge,
                color: SpendexColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: SpendexTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (widget.onViewAllTap != null)
            TextButton(
              onPressed: widget.onViewAllTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
              ),
              child: Text(
                'View All',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: SpendexColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.error != null) {
      return _buildErrorState();
    }

    if (widget.insights.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDataState();
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 140,
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < 2 ? 12 : 0,
                ),
                child: _ShimmerCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: SpendexColors.expense.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SpendexColors.expense.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Iconsax.info_circle,
                color: SpendexColors.expense,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                widget.error ?? 'Failed to load insights',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: SpendexColors.expense,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: widget.onViewAllTap,
                icon: const Icon(Iconsax.refresh, size: 16),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: SpendexColors.expense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              SpendexColors.primary.withValues(alpha: 0.05),
              SpendexColors.primaryLight.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SpendexColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Iconsax.magic_star,
                color: SpendexColors.primary,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'Generate insights to get started',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: SpendexColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: widget.onViewAllTap,
                icon: const Icon(Iconsax.magic_star, size: 16),
                label: const Text('Generate Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataState() {
    final displayInsights = widget.insights.take(3).toList();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: displayInsights.length,
            padEnds: false,
            itemBuilder: (context, index) {
              return GestureDetector(
                onPanDown: (_) => _onUserScroll(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InsightCard(
                    insight: displayInsights[index],
                    isCompact: true,
                    onTap: widget.onInsightTap != null
                        ? () => widget.onInsightTap!(displayInsights[index])
                        : null,
                    onDismiss: widget.onDismiss != null
                        ? () => widget.onDismiss!(displayInsights[index].id)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
        if (displayInsights.length > 1) ...[
          const SizedBox(height: 12),
          _buildDotIndicators(displayInsights.length),
        ],
      ],
    );
  }

  Widget _buildDotIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 10 : 8,
          height: _currentPage == index ? 10 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? SpendexColors.primary
                : SpendexColors.lightTextSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                SpendexColors.lightSurface,
                SpendexColors.lightSurface.withValues(alpha: 0.5),
                SpendexColors.lightSurface,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: SpendexColors.lightTextSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: SpendexColors.lightTextSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: SpendexColors.lightTextSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: SpendexColors.lightTextSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 10,
                      decoration: BoxDecoration(
                        color: SpendexColors.lightTextSecondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
