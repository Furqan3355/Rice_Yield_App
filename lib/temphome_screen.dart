// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   TextEditingController urlController = TextEditingController();
//   String result = "";
//   bool isLoading = false;
//   String? savedUrl;
//   bool showUrlInput = true;
  
//   // فائل اپ لوڈ کے لیے متغیرات
//   List<File> selectedFiles = [];
//   String? resultFilePath;
//   bool fileUploadInProgress = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedUrl();
//   }

//   Future<void> _loadSavedUrl() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       savedUrl = prefs.getString('api_url');
//       if (savedUrl != null && savedUrl!.isNotEmpty) {
//         urlController.text = savedUrl!;
//         showUrlInput = false;
//       }
//     });
//   }

//   Future<void> _saveUrl(String url) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('api_url', url);
//     setState(() {
//       savedUrl = url;
//       showUrlInput = false;
//     });
//   }

//   void _changeUrl() {
//     setState(() {
//       showUrlInput = true;
//     });
//   }

//   // فائلیں منتخب کرنے کا فنکشن
//   Future<void> _pickFiles() async {
//     try {
//       FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
//         allowMultiple: true,
//         type: FileType.custom,
//         allowedExtensions: ['txt', 'csv', 'json', 'xml'],
//       );

//       if (fileResult != null) {
//         setState(() {
//           selectedFiles = fileResult.paths.map((path) => File(path!)).toList();
//           resultFilePath = null;
//         });
//         showMessage("${selectedFiles.length} فائلیں منتخب کی گئی ہیں");
//       }
//     } catch (e) {
//       showMessage("فائل منتخب کرنے میں خرابی: $e");
//     }
//   }

//   // فائلیں اپ لوڈ کرنے کا فنکشن
//   Future<void> _uploadAndProcessFiles() async {
//     if (selectedFiles.isEmpty) {
//       showMessage("براہ کرم پہلے فائلیں منتخب کریں");
//       return;
//     }

//     if (savedUrl == null || savedUrl!.isEmpty) {
//       showMessage("پہلے API URL سیو کریں");
//       setState(() {
//         showUrlInput = true;
//       });
//       return;
//     }

//     setState(() {
//       isLoading = true;
//       fileUploadInProgress = true;
//       result = "";
//       resultFilePath = null;
//     });

//     try {
//       String apiUrl = savedUrl!.endsWith('/process-files') 
//           ? savedUrl! 
//           : "${savedUrl!.replaceAll(RegExp(r'/$'), '')}/process-files";

//       // Multipart request بنائیں
//       var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      
//       // فائلیں اٹیچ کریں
//       for (int i = 0; i < selectedFiles.length; i++) {
//         var file = selectedFiles[i];
//         request.files.add(
//           await http.MultipartFile.fromPath(
//             'file${i + 1}',
//             file.path,
//             filename: 'file${i + 1}.txt',
//           ),
//         );
//       }

//       // ریکویسٹ بھیجیں
//       var response = await request.send();
      
//       if (response.statusCode == 200) {
//         var responseData = await response.stream.bytesToString();
//         var jsonResponse = json.decode(responseData);
        
//         if (jsonResponse['success'] == true) {
//           setState(() {
//             result = "فائلیں کامیابی سے پراسیس ہو گئیں!";
//             resultFilePath = jsonResponse['result_file'];
//           });
//           showMessage("ریسلٹ فائل تیار ہو گئی: ${jsonResponse['result_file']}");
//         } else {
//           throw Exception(jsonResponse['error'] ?? "نامعلوم خرابی");
//         }
//       } else {
//         throw Exception("سرور ایرر: ${response.statusCode}");
//       }
//     } on http.ClientException catch (e) {
//       showMessage("کنیکشن نہیں ہو پا رہا: ${e.message}");
//     } catch (e) {
//       showMessage("ایرر: $e");
//     } finally {
//       setState(() {
//         isLoading = false;
//         fileUploadInProgress = false;
//       });
//     }
//   }

//   // ریسلٹ فائل ڈاؤن لوڈ کرنے کا فنکشن
//   Future<void> _downloadResultFile() async {
//     if (resultFilePath == null) {
//       showMessage("کوئی ریسلٹ فائل موجود نہیں");
//       return;
//     }

//     try {
//       String downloadUrl = "${savedUrl!.replaceAll(RegExp(r'/$'), '')}/download/$resultFilePath";
      
//       // Flutter میں فائل ڈاؤن لوڈ کے لیے WebView یا دیگر پیکیج استعمال کریں
//       // یہاں صرف URL دکھا رہے ہیں
//       showMessage("ڈاؤن لوڈ لنک: $downloadUrl");
      
//       // اگر آپ فائل ڈاؤن لوڈ کرنا چاہتے ہیں تو downloader پیکیج استعمال کریں
//       // Clipboard.setData(ClipboardData(text: downloadUrl));
//       // showMessage("ڈاؤن لوڈ لنک کاپی ہو گیا");
//     } catch (e) {
//       showMessage("ڈاؤن لوڈ میں خرابی: $e");
//     }
//   }

//   void saveApiUrl() {
//     if (urlController.text.isEmpty) {
//       showMessage("URL ڈالو");
//       return;
//     }

//     String url = urlController.text.trim();
//     if (!url.startsWith('http')) {
//       url = 'https://$url';
//       urlController.text = url;
//     }

//     _saveUrl(url);
//     showMessage("URL محفوظ ہو گیا");
//   }

//   void showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("فائل پراسیسنگ API"),
//         centerTitle: true,
//         actions: [
//           if (!showUrlInput && savedUrl != null)
//             IconButton(
//               onPressed: _changeUrl,
//               icon: Icon(Icons.settings),
//               tooltip: "URL تبدیل کریں",
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // URL ان پٹ سیکشن
//             if (showUrlInput)
//               Card(
//                 elevation: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.link, color: Colors.blue),
//                           SizedBox(width: 10),
//                           Text(
//                             "API URL ڈالیں",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       TextField(
//                         controller: urlController,
//                         decoration: InputDecoration(
//                           hintText: "جیسے: https://your-server.com",
//                           border: OutlineInputBorder(),
//                           prefixIcon: Icon(Icons.http),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       ElevatedButton.icon(
//                         onPressed: saveApiUrl,
//                         icon: Icon(Icons.save),
//                         label: Text("URL سیو کریں"),
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size(double.infinity, 50),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             // اگر URL سیو ہو چکا ہے تو اسے دکھائیں
//             if (!showUrlInput && savedUrl != null)
//               Card(
//                 color: Colors.green[50],
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle, color: Colors.green),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "API کنیکٹڈ",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green[800],
//                               ),
//                             ),
//                             Text(
//                               savedUrl!,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: _changeUrl,
//                         icon: Icon(Icons.edit, size: 20),
//                         tooltip: "تبدیل کریں",
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//             SizedBox(height: 20),

//             // فائل اپ لوڈ سیکشن
//             Card(
//               elevation: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.upload_file, color: Colors.purple),
//                         SizedBox(width: 10),
//                         Text(
//                           "فائلیں اپ لوڈ کریں",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       "2 فائلیں (TXT فارمیٹ) اپ لوڈ کریں",
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     SizedBox(height: 10),
                    
//                     // منتخب فائلوں کی لسٹ
//                     if (selectedFiles.isNotEmpty)
//                       Column(
//                         children: [
//                           for (int i = 0; i < selectedFiles.length; i++)
//                             ListTile(
//                               leading: Icon(Icons.insert_drive_file),
//                               title: Text(selectedFiles[i].path.split('/').last),
//                               subtitle: Text("فائل ${i + 1}"),
//                               trailing: IconButton(
//                                 icon: Icon(Icons.close, color: Colors.red),
//                                 onPressed: () {
//                                   setState(() {
//                                     selectedFiles.removeAt(i);
//                                   });
//                                 },
//                               ),
//                             ),
//                           SizedBox(height: 10),
//                         ],
//                       ),
                    
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _pickFiles,
//                             icon: Icon(Icons.add_box),
//                             label: Text(
//                               selectedFiles.isEmpty 
//                                 ? "فائلیں منتخب کریں" 
//                                 : "مزید فائلیں شامل کریں",
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.purple[100],
//                               foregroundColor: Colors.purple,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         if (selectedFiles.isNotEmpty)
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               setState(() {
//                                 selectedFiles.clear();
//                               });
//                             },
//                             icon: Icon(Icons.delete),
//                             label: Text("کلئیر"),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red[100],
//                               foregroundColor: Colors.red,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // پراسیس بٹن - Icons.auto_graph استعمال کریں
//             ElevatedButton(
//               onPressed: (isLoading || selectedFiles.isEmpty || savedUrl == null) 
//                   ? null 
//                   : _uploadAndProcessFiles,
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 backgroundColor: (selectedFiles.isNotEmpty && savedUrl != null) 
//                     ? Colors.green 
//                     : Colors.grey,
//               ),
//               child: fileUploadInProgress
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(color: Colors.white),
//                         SizedBox(width: 10),
//                         Text("فائلیں پراسیس ہو رہی ہیں..."),
//                       ],
//                     )
//                   : Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.auto_graph), // یہاں درست آئی کون استعمال کریں
//                         SizedBox(width: 10),
//                         Text(
//                           "فائلیں پراسیس کریں",
//                           style: TextStyle(fontSize: 18),
//                         ),
//                       ],
//                     ),
//             ),

//             SizedBox(height: 20),

//             // رزلٹ سیکشن
//             if (result.isNotEmpty || resultFilePath != null)
//               Card(
//                 color: Colors.blue[50],
//                 elevation: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(Icons.fact_check, color: Colors.blue),
//                           SizedBox(width: 10),
//                           Text(
//                             "پراسیسنگ رزلٹ",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.blue[800],
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 15),
                      
//                       if (result.isNotEmpty)
//                         Text(
//                           result,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.green[800],
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
                      
//                       if (resultFilePath != null) ...[
//                         SizedBox(height: 10),
//                         Container(
//                           padding: EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: Colors.blue),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "ریسلٹ فائل:",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue[800],
//                                 ),
//                               ),
//                               SizedBox(height: 5),
//                               Text(
//                                 resultFilePath!,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.blue[900],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         ElevatedButton.icon(
//                           onPressed: _downloadResultFile,
//                           icon: Icon(Icons.download),
//                           label: Text("ریسلٹ فائل ڈاؤن لوڈ کریں"),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             minimumSize: Size(double.infinity, 50),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),

//             // معلومات
//             Expanded(
//               child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (selectedFiles.isEmpty && savedUrl != null)
//                         Text(
//                           "ⓘ پہلے 2 فائلیں منتخب کریں",
//                           style: TextStyle(color: Colors.orange),
//                         ),
//                       SizedBox(height: 10),
//                       Text(
//                         "فائل پراسیسنگ API v2.0",
//                         style: TextStyle(color: Colors.grey, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }