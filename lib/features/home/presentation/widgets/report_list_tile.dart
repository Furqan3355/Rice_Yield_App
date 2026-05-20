import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import 'package:rice_yield_app/features/reports/domain/report_model.dart';
import '/core/theme/theme.dart';

class ReportListTile extends StatelessWidget {
  const ReportListTile({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);

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
          onTap: () {},
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
                  child: Icon(
                    _getStatusIcon(report.status),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reportId ?? 'Report ${report.shortDate}',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              report.time,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.secondary;
      case 'processing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
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
