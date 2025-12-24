import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../providers/app_providers.dart';
import '../../models/report_model.dart';
import '/screens/reports/reports_screen.dart';

class ReportsHistoryScreen extends ConsumerStatefulWidget {
  const ReportsHistoryScreen({super.key});

  @override
  ConsumerState<ReportsHistoryScreen> createState() => _ReportsHistoryScreenState();
}

class _ReportsHistoryScreenState extends ConsumerState<ReportsHistoryScreen> {
  String _selectedFilter = 'all'; 
  String _sortBy = 'newest'; 

  @override
  Widget build(BuildContext context) {
    // ✅ Watch reportsProvider taake UI refresh ho sake
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        centerTitle: true,
        actions: [
          // ✅ Refresh Button: Is par click karne se naye reports aa jayenge
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => ref.invalidate(reportsProvider),
          ),
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Processing', 'processing'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Failed', 'failed'),
                ],
              ),
            ),
          ),

          // Reports List
          Expanded(
            child: reportsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(error: e.toString()),
              data: (allReports) {
                List<Report> filteredReports = _applyFilters(allReports);
                
                if (filteredReports.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredReports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    // ✅ Fixed Report Item Call
                    return _ReportItem(report: report);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      showCheckmark: false,
      side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
    );
  }

  List<Report> _applyFilters(List<Report> reports) {
    List<Report> filtered = List.from(reports);
    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r.status.toLowerCase() == _selectedFilter).toList();
    }
    
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'oldest': return a.createdAt.compareTo(b.createdAt);
        case 'highest': return b.totalPanicles.compareTo(a.totalPanicles);
        case 'lowest': return a.totalPanicles.compareTo(b.totalPanicles);
        case 'newest':
        default: return b.createdAt.compareTo(a.createdAt);
      }
    });
    return filtered;
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildSortChip('Newest First', 'newest', setState),
                  _buildSortChip('Oldest First', 'oldest', setState),
                  _buildSortChip('Highest Panicles', 'highest', setState),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Apply'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, Function setState) {
    return ChoiceChip(
      label: Text(label),
      selected: _sortBy == value,
      onSelected: (_) => setState(() => this.setState(() => _sortBy = value)),
    );
  }
}

// ✅ FIXED: Report Item Widget with Real Stats mapping
class _ReportItem extends StatelessWidget {
  final Report report;
  const _ReportItem({required this.report});

  @override
  Widget build(BuildContext context) {
    final bool isProcessing = report.status.toLowerCase() == 'processing';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(report.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: isProcessing 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(_getStatusIcon(report.status), color: _getStatusColor(report.status), size: 24),
        ),
        title: Text(
          report.reportId ?? 'Analyzing Video...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            isProcessing 
              ? const Text('AI model is calculating...', style: TextStyle(color: Colors.orange))
              : Row(
                  children: [
                    const Icon(Iconsax.tree, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('${report.totalPanicles} panicles'),
                    const SizedBox(width: 12),
                    const Icon(Iconsax.weight, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('${report.totalWeight.toStringAsFixed(2)} kg'),
                  ],
                ),
            const SizedBox(height: 4),
            Text(DateFormat('dd MMM yyyy, hh:mm a').format(report.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
        trailing: const Icon(Iconsax.arrow_right_3, size: 18),
        onTap: isProcessing ? null : () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen(report: report)));
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'processing': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Iconsax.tick_circle;
      case 'processing': return Iconsax.clock;
      case 'failed': return Iconsax.close_circle;
      default: return Iconsax.info_circle;
    }
  }
}

// --- Loading/Error/Empty States (Aapka original code) ---
class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [const CircleAvatar(backgroundColor: Colors.white30), const SizedBox(width: 16), Container(width: 100, height: 10, color: Colors.white30)]),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Iconsax.warning_2, size: 60, color: Colors.red), const SizedBox(height: 16), Text(error)]));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Iconsax.document, size: 80, color: Colors.grey), const SizedBox(height: 16), const Text('No Reports Found')]));
  }
}