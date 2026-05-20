import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import '/core/theme/theme.dart';

/// Dashed-border video picker matching the home page design system.
class UploadDottedPicker extends StatelessWidget {
  const UploadDottedPicker({
    super.key,
    required this.selectedVideo,
    required this.onPick,
    required this.onClear,
    this.enabled = true,
  });

  final XFile? selectedVideo;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasVideo = selectedVideo != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: _DashedBorderPainter(
            color: hasVideo
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.45),
            radius: 20,
            strokeWidth: 2,
          ),
          child: Material(
            color: hasVideo
                ? AppColors.primary.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: enabled ? onPick : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 200),
                padding: const EdgeInsets.all(24),
                child: hasVideo
                    ? _SelectedVideoContent(
                        fileName: selectedVideo!.name,
                        onClear: enabled ? onClear : null,
                        onChange: enabled ? onPick : null,
                      )
                    : const _EmptyPickerContent(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyPickerContent extends StatelessWidget {
  const _EmptyPickerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Iconsax.video_add,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to select a video',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose from your gallery',
          style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade500),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'MP4 · 10–20 sec recommended',
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectedVideoContent extends StatelessWidget {
  const _SelectedVideoContent({
    required this.fileName,
    this.onClear,
    this.onChange,
  });

  final String fileName;
  final VoidCallback? onClear;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Iconsax.video,
                color: Colors.white,
                size: 40,
              ),
            ),
            if (onClear != null)
              Positioned(
                top: -8,
                right: -8,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: onClear,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Video ready',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            fileName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade600),
          ),
        ),
        if (onChange != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onChange,
            icon: const Icon(Iconsax.refresh, size: 18),
            label: const Text('Change video'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    const dashLength = 10.0;
    const gapLength = 7.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        final extractPath = metric.extractPath(
          distance,
          next.clamp(0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
