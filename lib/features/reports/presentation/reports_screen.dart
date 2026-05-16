import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import 'package:rice_yield_app/features/reports/domain/report_model.dart';
import 'package:rice_yield_app/features/reports/presentation/widgets/irrigation_instructions.dart';
import 'package:rice_yield_app/features/reports/application/pdf_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final Report report;
  const ReportScreen({super.key, required this.report});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final PdfService _pdfService = PdfService();
  bool _isGeneratingPdf = false;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    // ✅ FIX: Stats extraction direct from model getters or raw map
    final Map<String, dynamic> stats = report.stats ?? {};
    final Map<String, int> sizeCounts = report.sizeCounts ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isGeneratingPdf 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))
              : const Icon(Iconsax.export),
            onPressed: _isGeneratingPdf ? null : _generatePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Top Info Card
            _buildInfoCard(report),

            const SizedBox(height: 24),

            // ✅ Real-time Stats Grid (Using Model Getters)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  icon: Iconsax.tree,
                  value: '${report.totalPanicles}', // ✅ 14 or 13 from AI
                  label: 'Total Panicles',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Iconsax.weight,
                  value: '${report.totalWeight.toStringAsFixed(3)} kg', // ✅ 0.058 kg
                  label: 'Total Weight',
                  color: Colors.green,
                ),
              ],
            ),


            const SizedBox(height: 24),

            // --- Irrigation/Watering Instructions ---
            IrrigationInstructions(),

            // ✅ Size Distribution Progress Bars
            if (sizeCounts.isNotEmpty) _buildSizeDistribution(sizeCounts, report.totalPanicles),

            const SizedBox(height: 24),

            // ✅ Detailed Statistics Toggle
            _buildDetailToggle(),

            if (_showDetails) _buildDetailedSection(stats, report),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Report report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report ID', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(report.reportId ?? 'ID: ${report.id.substring(0, 8)}', 
                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              _buildStatusBadge(report.status),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(report.formattedDate, style: TextStyle(color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeDistribution(Map<String, int> sizeCounts, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [Icon(Iconsax.chart_1, size: 20), SizedBox(width: 12),
            Text('Size Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
          ),
          const SizedBox(height: 20),
          ...sizeCounts.entries.map((e) {
            final double percent = total > 0 ? (e.value / total) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${e.value} (${(percent * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.grey.shade100,
                    color: _getSizeColor(e.key),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Detailed Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(_showDetails ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedSection(Map<String, dynamic> stats, Report report) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildDetailRow('AI Processing Time', '${(stats['total_processing_time'] ?? 0).toStringAsFixed(2)}s'),
          _divider(),
          _buildDetailRow('Avg. Panicle Weight', '${(report.totalWeight / (report.totalPanicles > 0 ? report.totalPanicles : 1)).toStringAsFixed(4)} kg'),
          _divider(),
          _buildDetailRow('Raw Timestamp', stats['analysis_timestamp'] ?? 'N/A'),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);

  Color _getStatusColor(String status) {
    if (status.toLowerCase() == 'completed') return Colors.green;
    if (status.toLowerCase() == 'processing') return Colors.orange;
    return Colors.red;
  }

  Color _getSizeColor(String size) {
    if (size.toLowerCase() == 'large') return Colors.orange;
    if (size.toLowerCase() == 'medium') return Colors.blue;
    return Colors.green;
  }

  Future<void> _generatePdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfFile = await _pdfService.generateReportPdf(widget.report, context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('PDF Generated!'), action: SnackBarAction(label: 'Share', onPressed: () => _pdfService.sharePdf(pdfFile))));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }
}