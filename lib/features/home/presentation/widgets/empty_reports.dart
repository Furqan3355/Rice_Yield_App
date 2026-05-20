import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';

class EmptyReports extends StatelessWidget {
  final VoidCallback onUpload;

  const EmptyReports({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, strokeAlign: BorderSide.strokeAlignOutside),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.document_text,
              size: 48,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Reports Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a video of to start generating yield reports',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Iconsax.video_add, size: 20),
            label: const Text('New Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
