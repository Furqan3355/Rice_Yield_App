import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';

class HomeSpeakerButton extends ConsumerStatefulWidget {
  const HomeSpeakerButton({super.key});

  @override
  ConsumerState<HomeSpeakerButton> createState() => _HomeSpeakerButtonState();
}

class _HomeSpeakerButtonState extends ConsumerState<HomeSpeakerButton> {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  String _getInstructions(String userName) {
    return 'محترم ${userName} صاحب، السلام علیکم! چاول کی پیداوار کا تخمینہ لگانے والی ایپ میں خوش آمدید۔\n\n'
        '• ہوم پیج پر آپ فصل کا موجودہ خلاصہ اور پیداوار کے اہم اعداد و شمار دیکھ سکتے ہیں۔\n'
        '• نئی ویڈیو کا تجزیہ کرنے کے لیے "اپ لوڈ" کے بٹن کا انتخاب کریں۔\n'
        '• اپنی تمام سابقہ رپورٹس اور ریکارڈز دیکھنے کے لیے "ہسٹری" پر جائیں۔\n'
        '• اکاؤنٹ کی معلومات اور ترجیحات تبدیل کرنے کے لیے "پروفائل" کا انتخاب کریں۔\n'
        '• مزید رہنمائی کے لیے اسپیکر بٹن پر کلک کر کے ہدایات سنیں۔';
  }

  Future<void> _speak() async {
    setState(() => _isPlaying = true);
    final authState = ref.read(authNotifierProvider);
    final userName = authState.userName ?? 'صارف';
    await _tts.setLanguage('ur-PK');
    await _tts.setSpeechRate(0.4);
    await _tts.speak(_getInstructions(userName));
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      child: InkWell(
        onTap: _isPlaying ? null : _speak,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            _isPlaying ? Iconsax.volume_high : Iconsax.volume_high,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
