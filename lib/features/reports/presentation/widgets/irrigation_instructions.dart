import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class IrrigationInstructions extends StatefulWidget {
  @override
  State<IrrigationInstructions> createState() => _IrrigationInstructionsState();
}

class _IrrigationInstructionsState extends State<IrrigationInstructions> {
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  static const String urduInstructions =
      '• پانی کی سپلائی کو برقرار رکھیں، زمین کو ہمیشہ ہلکا گیلا رکھیں۔\n'
      '• زیادہ پانی سے بچیں، صرف ضرورت کے مطابق ہی آبپاشی کریں۔\n'
      '• ہر 7-10 دن بعد کھیت کی نگرانی کریں اور ضرورت پر ہی پانی دیں۔\n'
      '• فصل کی صحت پر نظر رکھیں، اور کسی بھی غیر معمولی نشانی پر ماہر سے مشورہ کریں۔';

  static const String englishInstructions =
      '• Maintain a steady water supply, keep the soil slightly moist.\n'
      '• Avoid overwatering, irrigate only as needed.\n'
      '• Inspect the field every 7-10 days and water only if necessary.\n'
      '• Monitor crop health and consult an expert if you notice anything unusual.';

  Future<void> _speak() async {
    setState(() => _isPlaying = true);
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5); // slower for English
    await _tts.speak(englishInstructions);
    await _tts.setLanguage('ur-PK');
    await _tts.setSpeechRate(0.4); // slower for Urdu
    await _tts.speak(urduInstructions);
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Field Instructions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(_isPlaying ? Icons.volume_up : Icons.volume_down, color: Colors.blue),
                tooltip: 'Listen',
                onPressed: _isPlaying ? null : _speak,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'English:',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          const Text(
            englishInstructions,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Text(
            'اردو:',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            urduInstructions,
            style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'NotoNastaliqUrdu'),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}