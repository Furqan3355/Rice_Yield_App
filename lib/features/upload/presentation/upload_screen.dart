import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import 'package:rice_yield_app/features/upload/presentation/widgets/upload_dotted_picker.dart';
import '/core/config/app_config.dart';
import '/core/theme/theme.dart';
import 'package:http_parser/http_parser.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  XFile? _selectedVideo;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickVideo() async {
    if (_isUploading) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedVideo = pickedFile);
    }
  }

  Future<void> _markAsFailed(String id) async {
    try {
      await ref
          .read(supabaseProvider)
          .from('reports')
          .update({'status': 'failed'})
          .eq('id', id);
      debugPrint('Report status updated to failed.');
    } catch (e) {
      debugPrint('Error updating failed status: $e');
    }
  }

  void _onStartAnalysisTap() {
    if (_selectedVideo == null) {
      final bottomPadding = MediaQuery.of(context).padding.bottom;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please upload a video then start analyzes',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            kBottomNavigationBarHeight + bottomPadding + 20,
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    _processVideo();
  }

  Future<void> _processVideo() async {
    if (_selectedVideo == null) return;

    final supabase = ref.read(supabaseProvider);
    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.5;
    });

    try {
      final XFile currentVideo = _selectedVideo!;

      final videoInsert = await supabase.from('video_uploads').insert({
        'user_id': userId,
        'file_url': currentVideo.path,
        'status': 'processing',
        'cloudinary_public_id': 'local_test',
      }).select().single();

      final reportInsert = await supabase.from('reports').insert({
        'user_id': userId,
        'video_id': videoInsert['id'],
        'status': 'processing',
      }).select().single();

      _startModelAnalysis(reportInsert['id'], currentVideo);

      setState(() {
        _isUploading = false;
        _selectedVideo = null;
        _uploadProgress = 0;
      });

      ref.read(routerProvider).push('/history');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing started in background...'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _startModelAnalysis(String reportId, XFile videoFile) async {
    final supabase = ref.read(supabaseProvider);

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(AppConfig.modelUrl));

      final bytes = await videoFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'video',
        bytes,
        filename: videoFile.name,
        contentType: MediaType('video', 'mp4'),
      );

      request.files.add(multipartFile);
      request.fields['report_id'] = reportId;

      var streamedResponse =
          await request.send().timeout(const Duration(minutes: 5));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await supabase.from('reports').update({
          'status': 'completed',
          'report_id': data['report_id']?.toString(),
          'total_panicles':
              data['total_panicles'] ?? data['stats']['total_panicles'],
          'total_weight_kg': data['stats']['total_weight_kg'],
          'yield_per_hectare_kg': data['stats']['yield_per_hectare_kg'],
          'stats': data['stats'],
          'chart_data': data['chart_data'],
        }).eq('id', reportId);
      } else {
        await _markAsFailed(reportId);
      }
    } catch (e) {
      debugPrint('Model analysis error: $e');
      await _markAsFailed(reportId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Video',
                style: AppTheme.headlineLarge.copyWith(
                  fontSize: 26,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Record your field and get AI-powered yield insights',
                style: AppTheme.bodyMedium.copyWith(color: AppColors.subtitle),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'How it works'),
              const SizedBox(height: 12),
              const _HowItWorksRow(),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Select your video'),
              const SizedBox(height: 12),
              UploadDottedPicker(
                selectedVideo: _selectedVideo,
                onPick: _pickVideo,
                onClear: () => setState(() => _selectedVideo = null),
                enabled: !_isUploading,
              ),
              if (_isUploading) ...[
                const SizedBox(height: 20),
                _UploadProgressCard(progress: _uploadProgress),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _onStartAnalysisTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isUploading
                      ? const SizedBox.shrink()
                      : const Icon(Iconsax.cloud_add, size: 22),
                  label: _isUploading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Start Analysis',
                          style: AppTheme.buttonText,
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Recording tips'),
              const SizedBox(height: 12),
              const _TipsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTheme.headlineMedium.copyWith(
        fontSize: 18,
        color: AppColors.primary,
      ),
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _StepChip(
            step: '1',
            icon: Iconsax.video_add,
            label: 'Select',
            subtitle: 'Pick video',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StepChip(
            step: '2',
            icon: Iconsax.chart_2,
            label: 'Analyze',
            subtitle: 'AI processing',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StepChip(
            step: '3',
            icon: Iconsax.chart_2,
            label: 'Results',
            subtitle: 'View report',
          ),
        ),
      ],
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.step,
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final String step;
  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            subtitle,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadProgressCard extends StatelessWidget {
  const _UploadProgressCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.timer_1,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Processing your video…',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few minutes. You can check History for updates.',
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  static const _tips = [
    (Iconsax.lamp, 'Good lighting', 'Film in daylight or well-lit fields'),
    (Iconsax.video_play, 'Steady camera', 'Keep the phone stable while recording'),
    (Iconsax.timer_1, '10–20 seconds', 'Short clips work best for analysis'),
    (Iconsax.tick_circle, 'Clear panicles', 'Focus on rice plants in the frame'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        children: [
          for (var i = 0; i < _tips.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _TipRow(
              icon: _tips[i].$1,
              title: _tips[i].$2,
              subtitle: _tips[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTheme.bodyMedium.copyWith(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
