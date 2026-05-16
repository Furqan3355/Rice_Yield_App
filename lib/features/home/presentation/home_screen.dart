// home_screen.dart - UPDATED PROFESSIONAL VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/features/reports/domain/report_model.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';

import 'package:rice_yield_app/features/home/presentation/widgets/stat_card.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/quick_action_card.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/report_list_tile.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/loading_reports.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/error_widget_display.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/empty_reports.dart';
import 'package:rice_yield_app/features/home/presentation/widgets/home_audio_instructions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final reportsAsync = ref.watch(reportsProvider);
    final reports = reportsAsync.asData?.value ?? <Report>[];

    final today = DateTime.now();
    final todayReports = reports.where((r) =>
      r.createdAt.year == today.year &&
      r.createdAt.month == today.month &&
      r.createdAt.day == today.day
    ).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(reportsProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Audio Instructions Button
                    const HomeAudioInstructions(),
                    const SizedBox(height: 8),
                    // Header with User Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, d MMM').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                                Text(
                                  'Hi, ${authState.userName?.split(' ')[0] ?? 'User'}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryColor, 
                            child: Text(
                              authState.userName?[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), 
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          icon: Iconsax.document_text_1,
                          value: reports.length.toString(),
                          label: 'Total Reports',
                          color: Colors.blueAccent,
                        ),
                        StatCard(
                          icon: Iconsax.calendar_tick,
                          value: todayReports.length.toString(),     
                          label: 'Today',
                          color: Colors.green,
                        ),
                        StatCard(
                          icon: Iconsax.send_square,
                          value: reports.fold<int>(0, (sum, r) => sum + r.totalPanicles).toString(),
                          label: 'Total Panicles',
                          color: Colors.orange,
                        ),
                        StatCard(
                          icon: Iconsax.weight_1,
                          value: '${reports.fold<double>(0, (sum, r) => sum + r.totalWeight).toStringAsFixed(1)} kg',
                          label: 'Total Weight',
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), 
                      children: [
                        QuickActionCard(
                          icon: Iconsax.video_add,
                          label: 'Upload Video',
                          subtitle: 'Process new data',
                          color: AppColors.primaryColor,
                          onTap: () => ref.read(routerProvider).push('/upload'),
                        ),
                        const SizedBox(height: 12),
                        QuickActionCard(
                          icon: Iconsax.chart_2,
                          label: 'View History',
                          subtitle: 'All reports',
                          color: Colors.indigo,
                          onTap: () => ref.read(routerProvider).push('/history'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Activity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.read(routerProvider).push('/history'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryColor, 
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          child: const Row(
                            children: [
                              Text('View All'),
                              SizedBox(width: 4),
                              Icon(Iconsax.arrow_right_3, size: 16), 
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Recent Reports List
                    reportsAsync.when(
                      loading: () => const LoadingReports(),        
                      error: (e, _) => ErrorWidgetDisplay(error: e.toString()),
                      data: (reports) {
                        if (reports.isEmpty) {
                          return EmptyReports(onUpload: () => ref.read(routerProvider).push('/upload'));
                        }

                        final itemCount = reports.length > 3 ? 3 : reports.length;
                        return Column(
                          children: List.generate(itemCount * 2 - 1, (i) {
                            if (i.isOdd) {
                              return const SizedBox(height: 12);
                            }
                            final index = i ~/ 2;
                            final report = reports[index];
                            return ReportListTile(report: report);
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
