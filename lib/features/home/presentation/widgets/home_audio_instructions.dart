import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';

class HomeAudioInstructions extends ConsumerStatefulWidget {
  const HomeAudioInstructions({super.key});

  @override
  ConsumerState<HomeAudioInstructions> createState() => _HomeAudioInstructionsState();
}

class _HomeAudioInstructionsState extends ConsumerState<HomeAudioInstructions> {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

   String _getInstructions(String userName) {
  return 'محترم ${userName} صاحب، السلام علیکم! چاول کی پیداوار کا تخمینہ لگانے والی ایپ میں خوش آمدید۔\n\n'
      '• ہوم پیج پر آپ فصل کا موجودہ خلاصہ اور پیداوار کے اہم اعداد و شمار دیکھ سکتے ہیں۔\n'
      '• نئی ویڈیو کا تجزیہ کرنے کے لیے "اپ لوڈ" کے بٹن کا انتخاب کریں۔\n'
      '• اپنی تمام سابقہ رپورٹس اور ریکارڈز دیکھنے کے لیے "ہسٹری" پر جائیں۔\n'
      '• اکاؤنٹ کی معلومات اور ترجیحات تبدیل کرنے کے لیے "پروفائل" کا انتخاب کریں۔\n'
      '• مزید رہنمائی کے لیے اوپر دیے گئے آڈیو بٹن پر کلک کر کے ہدایات سنیں۔';
}

  Future<void> _speak() async {
    setState(() => _isPlaying = true);
    final authState = ref.read(authNotifierProvider);
    String userName = authState.userName ?? 'صارف';
    await _tts.setLanguage('ur-PK');
    await _tts.setSpeechRate(0.4);
    await _tts.speak(_getInstructions(userName));
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: Icon(_isPlaying ? Icons.volume_up : Icons.volume_down, color: Colors.blue, size: 28),
        tooltip: 'آڈیو ہدایت سنیں (اردو)',
        onPressed: _isPlaying ? null : _speak,
      ),
    );
  }
}
