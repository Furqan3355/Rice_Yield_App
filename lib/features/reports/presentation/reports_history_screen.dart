import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import 'package:rice_yield_app/features/reports/domain/report_model.dart';
import 'package:rice_yield_app/features/reports/presentation/reports_screen.dart';
import 'package:rice_yield_app/features/reports/presentation/widgets/history_filter_panel.dart';
import '/core/theme/theme.dart';

class ReportsHistoryScreen extends ConsumerStatefulWidget {
  const ReportsHistoryScreen({super.key});

  @override
  ConsumerState<ReportsHistoryScreen> createState() =>
      _ReportsHistoryScreenState();
}

class _ReportsHistoryScreenState extends ConsumerState<ReportsHistoryScreen> {
  String _selectedFilter = 'all';
  String _sortBy = 'newest';

  final GlobalKey _filterButtonKey = GlobalKey();

  List<Report> _applyFilters(List<Report> reports) {
    var filtered = List<Report>.from(reports);
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((r) => r.status.toLowerCase() == _selectedFilter)
          .toList();
    }

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'oldest':
          return a.createdAt.compareTo(b.createdAt);
        case 'highest':
          return b.totalPanicles.compareTo(a.totalPanicles);
        case 'lowest':
          return a.totalPanicles.compareTo(b.totalPanicles);
        case 'newest':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });
    return filtered;
  }

  Future<void> _showFilterPanel() async {
    final box =
        _filterButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final buttonTopLeft = box.localToGlobal(Offset.zero);
    final panelTop = buttonTopLeft.dy + box.size.height + 10;
    final panelLeft = buttonTopLeft.dx;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close filters',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final scale = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        final screenWidth = MediaQuery.of(dialogContext).size.width;
        const panelWidth = 280.0;
        final safeLeft = panelLeft.clamp(
          12.0,
          screenWidth - panelWidth - 12,
        );

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Stack(
              children: [
                Positioned(
                  left: safeLeft,
                  top: panelTop,
                  child: ScaleTransition(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: HistoryFilterPanel(
                      selectedStatus: _selectedFilter,
                      selectedSort: _sortBy,
                      onStatusChanged: (v) {
                        setState(() => _selectedFilter = v);
                        setDialogState(() {});
                      },
                      onSortChanged: (v) {
                        setState(() => _sortBy = v);
                        setDialogState(() {});
                      },
                      onClose: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderIconButton({
    Key? buttonKey,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Material(
      key: buttonKey,
      color: isActive
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 22,
            color: isActive ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(reportsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Analysis History',
                              style: AppTheme.headlineLarge.copyWith(
                                fontSize: 26,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Review and open your past yield reports',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppColors.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildHeaderIconButton(
                        icon: Iconsax.refresh,
                        onPressed: () => ref.invalidate(reportsProvider),
                        isActive: false,
                      ),
                      const SizedBox(width: 8),
                      _buildHeaderIconButton(
                        buttonKey: _filterButtonKey,
                        icon: Iconsax.filter,
                        onPressed: _showFilterPanel,
                        isActive: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: _HistoryTipsBanner()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ...reportsAsync.when(
                loading: () => [
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(child: _LoadingListPlaceholder()),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      error: e.toString(),
                      onRetry: () => ref.invalidate(reportsProvider),
                    ),
                  ),
                ],
                data: (allReports) {
                  final filtered = _applyFilters(allReports);
                  if (filtered.isEmpty) {
                    return [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(
                          hasReports: allReports.isNotEmpty,
                        ),
                      ),
                    ];
                  }
                  return [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _HistoryReportCard(
                            report: filtered[index],
                          );
                        },
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTipsBanner extends StatelessWidget {
  const _HistoryTipsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.info_circle, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap a completed report to view full analysis. Use filters to sort by date or panicle count.',
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryReportCard extends StatelessWidget {
  const _HistoryReportCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final isProcessing = report.status.toLowerCase() == 'processing';
    final statusColor = _statusColor(report.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isProcessing
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportScreen(report: report),
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _statusIcon(report.status),
                          color: Colors.white,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reportId ?? 'Analyzing video…',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (isProcessing)
                        Text(
                          'AI model is calculating…',
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.warning,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Iconsax.tree,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${report.totalPanicles} panicles',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Iconsax.weight_1,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${report.totalWeight.toStringAsFixed(1)} kg',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Text(
                        report.formattedDate,
                        style: AppTheme.bodyMedium.copyWith(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    if (!isProcessing) ...[
                      const SizedBox(height: 8),
                      Icon(
                        Iconsax.arrow_right_3,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.primary;
      case 'processing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Iconsax.tick_circle;
      case 'processing':
        return Iconsax.timer_1;
      case 'failed':
        return Iconsax.close_circle;
      default:
        return Iconsax.document_text;
    }
  }
}

class _LoadingListPlaceholder extends StatelessWidget {
  const _LoadingListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i < 3 ? 12 : 0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 56, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Could not load reports',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(color: AppColors.subtitle),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasReports});

  final bool hasReports;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasReports ? Iconsax.filter : Iconsax.document_text,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasReports ? 'No matching reports' : 'No reports yet',
              style: AppTheme.headlineMedium.copyWith(
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasReports
                  ? 'Try changing your filters to see more results.'
                  : 'Upload a video from the Upload tab to generate your first report.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(color: AppColors.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}
