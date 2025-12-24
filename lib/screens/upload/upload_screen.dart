import 'dart:io';
import 'dart:convert';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import '../../providers/app_providers.dart';
import '/config/app_config.dart';
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedVideo = pickedFile);
    }
  }

  // ✅ Model Analysis Background Function
  // Future<void> _startModelAnalysis(String reportId, String videoUrl) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('https://hk3355-hallakukhan.hf.space/analyze'),
  //       body: jsonEncode({
  //         'report_id': reportId,
  //         'video_url': videoUrl, // Filhaal local path ja raha hai jab tak Cloudinary set nahi hota
  //       }),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final supabase = ref.read(supabaseProvider);

  //       // ✅ Background mein report update karna jab model result bhej de
  //       await supabase.from('reports').update({
  //         'status': 'completed',
  //         'total_panicles': data['total_panicles'] ?? 0,
  //         'total_weight_kg': data['total_weight_kg'] ?? 0.0,
  //         'prediction_data': data,
  //       }).eq('id', reportId);
  //     }
  //   } catch (e) {
  //     debugPrint("Background Analysis Error: $e");
  //   }
  // }
// MediaType ke liye upar add karein

// Future<void> _startModelAnalysis(String reportId, XFile videoFile) async {
//   final supabase = ref.read(supabaseProvider);
  
//   try {
//     print("🚀 Sending binary video to model (Web/Mobile Compatible)...");

//     var request = http.MultipartRequest('POST', Uri.parse(AppConfig.modelUrl));
    
//     // ✅ FIX: Web ke liye bytes use karein
//     final bytes = await videoFile.readAsBytes();
//     final multipartFile = http.MultipartFile.fromBytes(
//       'video', // Key name
//       bytes,
//       filename: videoFile.name,
//       contentType: MediaType('video', 'mp4'), // Video format
//     );

//     request.files.add(multipartFile);
//     request.fields['report_id'] = reportId;

//     var streamedResponse = await request.send().timeout(const Duration(minutes: 5));
//     var response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("✅ Model Data Received: ${data['stats']}");

//       await supabase.from('reports').update({
//         'status': 'completed',
//         'report_id': data['report_id']?.toString(),
//         'stats': data['stats'],
//         'chart_data': data['chart_data'],
//       }).eq('id', reportId);
      
//       print("🎊 Results saved!");
//     } else {
//       print("❌ Server Error: ${response.body}");
//       await _markAsFailed(reportId);
//     }
//   } catch (e) {
//     print("🚨 Request Failed: $e");
//     await _markAsFailed(reportId);
//   }
// }
// Ye function database mein status ko 'failed' kar dega agar model error de
Future<void> _markAsFailed(String id) async {
  try {
    await ref.read(supabaseProvider)
        .from('reports')
        .update({'status': 'failed'})
        .eq('id', id);
    print("⚠️ Report status updated to failed.");
  } catch (e) {
    print("🚨 Error updating failed status: $e");
  }
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
      // ✅ FIX 1: Type mismatch khatam kiya. directPath ki jagah XFile hi use karein.
      final XFile currentVideo = _selectedVideo!;

      // 1. Database mein Entry (Status: Processing)
      final videoInsert = await supabase.from('video_uploads').insert({
        'user_id': userId,
        'file_url': currentVideo.path, // String path database ke liye
        'status': 'processing',
        'cloudinary_public_id': 'local_test'
      }).select().single();

      final reportInsert = await supabase.from('reports').insert({
        'user_id': userId,
        'video_id': videoInsert['id'],
        'status': 'processing',
      }).select().single();

      // ✅ FIX 2: Poora XFile object bhej rahe hain String path nahi
      _startModelAnalysis(reportInsert['id'], currentVideo);

      setState(() {
        _isUploading = false;
        _selectedVideo = null;
      });

      // ✅ 3. History Page par bhej dein
      ref.read(routerProvider).push('/history');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing started in background...')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ✅ Model Analysis Function (Web/Mobile Compatible)
  Future<void> _startModelAnalysis(String reportId, XFile videoFile) async {
  final supabase = ref.read(supabaseProvider);
  
  try {
    print("🚀 Uploading binary video: ${videoFile.name}");

    var request = http.MultipartRequest('POST', Uri.parse(AppConfig.modelUrl));
    
    final bytes = await videoFile.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'video', 
      bytes,
      filename: videoFile.name,
      contentType: MediaType('video', 'mp4'),
    );

    request.files.add(multipartFile);
    request.fields['report_id'] = reportId;

    var streamedResponse = await request.send().timeout(const Duration(minutes: 5));
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Model Data Received: $data");

      // ✅ Mapping matches your JSON exactly
      await supabase.from('reports').update({
        'status': 'completed',
        'report_id': data['report_id']?.toString(), // "1766502461"
        'total_panicles': data['total_panicles'] ?? data['stats']['total_panicles'],
        'total_weight_kg': data['stats']['total_weight_kg'],
        'yield_per_hectare_kg': data['stats']['yield_per_hectare_kg'],
        'stats': data['stats'],
        'chart_data': data['chart_data'],
      }).eq('id', reportId);
      
      print("🎊 Sab kuch sahi save ho gaya!");
    } else {
      print("❌ Server Error: ${response.body}");
      await _markAsFailed(reportId);
    }
  } catch (e) {
    print("🚨 Mapping Error: $e");
    await _markAsFailed(reportId);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (_selectedVideo != null) _buildVideoPreview(),
            if (_isUploading) _buildProgressBar(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Iconsax.video_circle, size: 60, color: Colors.blue.shade600),
          const SizedBox(height: 16),
          const Text('Analyze Rice Panicles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Stack(
      children: [
        Container(
          height: 200, width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FutureBuilder<File?>(
              future: _generateThumbnail(),
              builder: (context, snapshot) {
                if (snapshot.hasData) return Image.file(snapshot.data!, fit: BoxFit.cover);
                return const Center(child: Icon(Iconsax.video));
              },
            ),
          ),
        ),
        Positioned(top: 8, right: 8, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(onPressed: () => setState(() => _selectedVideo = null), icon: const Icon(Icons.close, color: Colors.white)))),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: LinearProgressIndicator(value: _uploadProgress, backgroundColor: Colors.green.shade100, color: Colors.green),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _isUploading ? null : _pickVideo, icon: const Icon(Iconsax.video_add), label: Text(_selectedVideo == null ? 'Select Video' : 'Change Video'))),
        const SizedBox(height: 12),
        if (_selectedVideo != null && !_isUploading)
          SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: _processVideo, icon: const Icon(Iconsax.cloud_add), label: const Text('Start Processing'))),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
      child: const Column(
        children: [
          Text('💡 Tips: Good lighting, Steady camera, 10-20 sec duration.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<File?> _generateThumbnail() async {
    if (_selectedVideo == null) return null;
    final path = await VideoThumbnail.thumbnailFile(video: _selectedVideo!.path, imageFormat: ImageFormat.JPEG, quality: 50);
    return path != null ? File(path) : null;
  }
}