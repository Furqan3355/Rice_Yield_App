import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ErrorWidgetDisplay extends StatelessWidget {
  final String error;

  const ErrorWidgetDisplay({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.warning_2, color: Colors.red, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 13,
              color: Colors.red.shade300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
