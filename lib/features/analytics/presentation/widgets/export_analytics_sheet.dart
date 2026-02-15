import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme.dart';
import '../providers/analytics_provider.dart';

/// Bottom sheet for exporting analytics reports.
class ExportAnalyticsSheet extends ConsumerStatefulWidget {
  const ExportAnalyticsSheet({super.key});

  @override
  ConsumerState<ExportAnalyticsSheet> createState() => _ExportAnalyticsSheetState();
}

class _ExportAnalyticsSheetState extends ConsumerState<ExportAnalyticsSheet> {
  String? _exportingFormat;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(analyticsStateProvider);

    ref.listen<AnalyticsState>(analyticsStateProvider, (previous, next) {
      if ((previous?.isExporting ?? false) && !next.isExporting) {
        if (next.exportUrl != null) {
          _shareExport(next.exportUrl!);
        } else if (next.error != null) {
          _showError(next.error!);
        }
        setState(() {
          _exportingFormat = null;
        });
      }
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SpendexTheme.radiusXl),
          topRight: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.export_1,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Analytics',
                          style: SpendexTheme.headlineSmall.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Choose a format to export your analytics report',
                          style: SpendexTheme.bodySmall.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingXl),
            _ExportOption(
              icon: Iconsax.document_text,
              title: 'PDF Report',
              subtitle: 'Visual report with charts and summaries',
              format: 'pdf',
              isExporting: _exportingFormat == 'pdf' && state.isExporting,
              isDark: isDark,
              onTap: () => _startExport('pdf'),
            ),
            Divider(
              height: 1,
              indent: SpendexTheme.spacingLg,
              endIndent: SpendexTheme.spacingLg,
              color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            ),
            _ExportOption(
              icon: Iconsax.document_download,
              title: 'CSV Spreadsheet',
              subtitle: 'Raw data for spreadsheet applications',
              format: 'csv',
              isExporting: _exportingFormat == 'csv' && state.isExporting,
              isDark: isDark,
              onTap: () => _startExport('csv'),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
              child: Container(
                padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                decoration: BoxDecoration(
                  color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  border: Border.all(
                    color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 18,
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                    const SizedBox(width: SpendexTheme.spacingSm),
                    Expanded(
                      child: Text(
                        'Export will include data from the currently selected date range',
                        style: SpendexTheme.labelSmall.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
          ],
        ),
      ),
    );
  }

  void _startExport(String format) {
    if (_exportingFormat != null) {
      return;
    }

    setState(() {
      _exportingFormat = format;
    });
    ref.read(analyticsStateProvider.notifier).exportAnalytics(format);
  }

  Future<void> _shareExport(String url) async {
    Navigator.of(context).pop();

    final result = await Share.share(
      'My Spendex Analytics Report: $url',
      subject: 'Spendex Analytics Report',
    );

    if (result.status == ShareResultStatus.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report shared successfully',
            style: SpendexTheme.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export failed: $message',
          style: SpendexTheme.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: SpendexColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            if (_exportingFormat != null) {
              _startExport(_exportingFormat!);
            }
          },
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.format,
    required this.isExporting,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String format;
  final bool isExporting;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingLg,
        vertical: SpendexTheme.spacingSm,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: SpendexColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        ),
        child: isExporting
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    SpendexColors.primary,
                  ),
                ),
              )
            : Icon(
                icon,
                color: SpendexColors.primary,
                size: 24,
              ),
      ),
      title: Text(
        title,
        style: SpendexTheme.titleMedium.copyWith(
          color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: SpendexTheme.bodySmall.copyWith(
          color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
        ),
      ),
      trailing: isExporting
          ? null
          : Icon(
              Iconsax.arrow_right_3,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              size: 20,
            ),
      onTap: isExporting ? null : onTap,
    );
  }
}
