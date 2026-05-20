import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import '/core/theme/theme.dart';

class HistoryFilterPanel extends StatelessWidget {
  const HistoryFilterPanel({
    super.key,
    required this.selectedStatus,
    required this.selectedSort,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onClose,
  });

  final String selectedStatus;
  final String selectedSort;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onClose;

  static const statusOptions = [
    ('All', 'all'),
    ('Completed', 'completed'),
    ('Processing', 'processing'),
    ('Failed', 'failed'),
  ];

  static const sortOptions = [
    ('Newest first', 'newest'),
    ('Oldest first', 'oldest'),
    ('Highest panicles', 'highest'),
    ('Lowest panicles', 'lowest'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Container(
        width: 280,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: AppTheme.headlineMedium.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Iconsax.close_circle,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Status',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statusOptions
                  .map(
                    (o) => _FilterOptionChip(
                      label: o.$1,
                      value: o.$2,
                      groupValue: selectedStatus,
                      onSelected: onStatusChanged,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Sort by',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortOptions
                  .map(
                    (o) => _FilterOptionChip(
                      label: o.$1,
                      value: o.$2,
                      groupValue: selectedSort,
                      onSelected: onSortChanged,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOptionChip extends StatelessWidget {
  const _FilterOptionChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return Material(
      color: selected
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onSelected(value),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
