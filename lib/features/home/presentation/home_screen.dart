import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import 'package:rice_yield_app/features/reports/domain/report_model.dart';
import '/core/theme/theme.dart';

import 'package:rice_yield_app/features/home/presentation/widgets/home_stats_grid.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/quick_action_card.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/report_list_tile.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/loading_reports.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/error_widget_display.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/empty_reports.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/home_audio_instructions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String _greetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good morning! Here's your farm overview.";
    }
    if (hour < 17) {
      return "Good afternoon! Here's your farm overview.";
    }
    return "Good evening! Here's your farm overview.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final reportsAsync = ref.watch(reportsProvider);
    final reports = reportsAsync.asData?.value ?? <Report>[];

    final today = DateTime.now();
    final todayReports = reports.where((r) =>
        r.createdAt.year == today.year &&
        r.createdAt.month == today.month &&
        r.createdAt.day == today.day);

    final firstName = authState.userName?.split(' ').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(reportsProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi $firstName,',
                                style: AppTheme.headlineLarge.copyWith(
                                  fontSize: 26,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _greetingSubtitle(),
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppColors.subtitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const HomeSpeakerButton(),
                      ],
                    ),

                    const SizedBox(height: 28),

                    HomeStatsGrid(
                      totalReports: reports.length,
                      todayCount: todayReports.length,
                      totalPanicles: reports.fold<int>(
                        0,
                        (sum, r) => sum + r.totalPanicles,
                      ),
                      totalWeight:
                          '${reports.fold<double>(0, (sum, r) => sum + r.totalWeight).toStringAsFixed(1)} kg',
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Quick Actions',
                      style: AppTheme.headlineMedium.copyWith(
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        QuickActionCard(
                          icon: Iconsax.video_add,
                          label: 'Upload Video',
                          subtitle: 'Process new field data',
                          onTap: () => ref.read(routerProvider).push('/upload'),
                        ),
                        const SizedBox(height: 12),
                        QuickActionCard(
                          icon: Iconsax.chart_2,
                          label: 'View History',
                          subtitle: 'Browse all your reports',
                          onTap: () =>
                              ref.read(routerProvider).push('/history'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: AppTheme.headlineMedium.copyWith(
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              ref.read(routerProvider).push('/history'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 4),
                              Icon(Iconsax.arrow_right_3, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    reportsAsync.when(
                      loading: () => const LoadingReports(),
                      error: (e, _) =>
                          ErrorWidgetDisplay(error: e.toString()),
                      data: (reports) {
                        if (reports.isEmpty) {
                          return EmptyReports(
                            onUpload: () =>
                                ref.read(routerProvider).push('/upload'),
                          );
                        }

                        final itemCount = reports.length > 3 ? 3 : reports.length;
                        return Column(
                          children: List.generate(itemCount * 2 - 1, (i) {
                            if (i.isOdd) {
                              return const SizedBox(height: 12);
                            }
                            final index = i ~/ 2;
                            return ReportListTile(report: reports[index]);
                          }),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
