import 'package:intl/intl.dart';

class Report {
  final String id;
  final String userId;
  final String status;
  final DateTime createdAt;
  
  // API Response fields (Direct from your CURL output)
  final String? reportId;
  final Map<String, dynamic>? chartData;
  final Map<String, dynamic>? stats; 
  final bool success;

  Report({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.reportId,
    this.chartData,
    this.stats,
    this.success = true,
  });

  // ✅ Getters for UI (Fixing 'time' and others)
  String get time => DateFormat('hh:mm a').format(createdAt); // Ye error fix karega
  String get formattedDate => DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  String get shortDate => DateFormat('dd/MM/yy').format(createdAt);

  // ✅ Stats extraction from AI Model JSON
  int get totalPanicles => stats?['total_panicles'] ?? 0;
  double get totalWeight => (stats?['total_weight_kg'] ?? 0.0).toDouble();
  double get yieldPerHectare => (stats?['yield_per_hectare_kg'] ?? 0.0).toDouble();
  double get averagePanicleWeight => totalPanicles > 0 ? totalWeight / totalPanicles : 0.0;

  // ✅ Size counts parsing for Charts/UI
  Map<String, int>? get sizeCounts {
    if (stats?['size_counts'] == null) return null;
    return Map<String, int>.from(stats!['size_counts']);
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      reportId: json['report_id']?.toString(), 
      chartData: json['chart_data'], 
      stats: json['stats'], 
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'report_id': reportId,
      'chart_data': chartData,
      'stats': stats,
      'success': success,
    };
  }
}