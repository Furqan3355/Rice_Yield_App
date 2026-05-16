import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';


import 'package:http/http.dart' as http;

// Usage:
// SUPABASE_URL=https://xyz.supabase.co \
// SUPABASE_KEY=your_service_role_key \
// TARGET_USER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
// dart run tools/cleanup_mock_reports.dart

Future<void> main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final supabaseKey = Platform.environment['SUPABASE_KEY'];
  final targetUserId = Platform.environment['TARGET_USER_ID'];

  if (supabaseUrl == null || supabaseKey == null || targetUserId == null) {
    debugPrint('Please set SUPABASE_URL, SUPABASE_KEY and TARGET_USER_ID env variables.');
    exit(1);
  }

  final client = http.Client();
  try {
    final listUrl = Uri.parse('$supabaseUrl/rest/v1/reports?user_id=eq.$targetUserId&select=id,prediction');

    final resp = await client.get(listUrl, headers: {
      'apikey': supabaseKey,
      'Authorization': 'Bearer $supabaseKey',
      'Accept': 'application/json',
    });

    if (resp.statusCode != 200) {
      debugPrint('Failed to fetch reports: ${resp.statusCode} ${resp.body}');
      exit(2);
    }

    final List<dynamic> reports = json.decode(resp.body) as List<dynamic>;

    final idsToDelete = <String>[];

    for (final r in reports) {
      final id = r['id'];
      final pred = r['prediction'];
      if (pred == null) continue;

      bool isMock = false;
      if (pred is Map) {
        isMock = pred.values.any((v) => v is String && v.toLowerCase().contains('mock')) ||
                 pred.values.any((v) => v.toString().contains('5.2')) ||
                 pred.values.any((v) => v.toString().toLowerCase().contains('tons'));
      } else if (pred is String) {
        final s = pred.toLowerCase();
        isMock = s.contains('mock') || s.contains('5.2');
      }

      if (isMock) idsToDelete.add(id.toString());
    }

  
    if (idsToDelete.isEmpty) return;

    for (final id in idsToDelete) {
      final delUrl = Uri.parse('$supabaseUrl/rest/v1/reports?id=eq.$id');
      final dresp = await client.delete(delUrl, headers: {
        'apikey': supabaseKey,
        'Authorization': 'Bearer $supabaseKey',
        'Prefer': 'return=minimal',
      });
      if (dresp.statusCode == 204) {
        debugPrint('Deleted $id');
      } else {
        debugPrint('Failed to delete $id: ${dresp.statusCode} ${dresp.body}');
      }
    }


  } finally {
    client.close();
  }
}
