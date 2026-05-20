import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/auth_back_button.dart';
import '/core/theme/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How do I upload a video?',
      'Go to the Upload tab, tap the dotted area to pick a video from your '
          'gallery, then press Start Analysis. Processing continues in the background.',
    ),
    (
      'Where can I see my reports?',
      'Open the History tab to view all analyses. Tap a completed report to '
          'see panicle counts, weight, and charts.',
    ),
    (
      'Why is my report still processing?',
      'The AI model may take a few minutes depending on video length and server '
          'load. Pull to refresh on History or Home to check the latest status.',
    ),
    (
      'How do I change my name?',
      'On the Profile tab, tap Edit Profile Name, enter your new name, and save.',
    ),
    (
      'Who can I contact for help?',
      'Email support@riceyield.app or call our helpline at +92-300-0000000 '
          '(Mon–Sat, 9am–5pm PKT).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const AuthBackButton(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Help & Support',
                        style: AppTheme.headlineLarge.copyWith(
                          fontSize: 24,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Iconsax.message_question,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need assistance?',
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Browse FAQs below or reach out to our team.',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Frequently asked questions',
                    style: AppTheme.headlineMedium.copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._faqs.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FaqTile(question: f.$1, answer: f.$2),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey.shade600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
