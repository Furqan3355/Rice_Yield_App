// pdf_service.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/report_model.dart';

class PdfService {
  // 1. Generate PDF from Report
  Future<File> generateReportPdf(Report report, BuildContext context) async {
    try {
      // Create PDF document
      final pdf = pw.Document();
      
      // Get data from report
      final stats = report.stats ?? {};
      final chartData = report.chartData ?? {};
      final sizeCounts = stats['size_counts'] ?? {};
      final totalPanicles = stats['total_panicles'] ?? 0;

      
      // Add pages to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Cover Page
            _buildCoverPage(report),
            pw.SizedBox(height: 20),
            
            // Summary Section
            _buildSummarySection(stats),
            pw.SizedBox(height: 20),
            
            // Chart Section
            _buildChartSection(chartData, sizeCounts),
            pw.SizedBox(height: 20),
            
            // Size Distribution
            _buildSizeDistribution(sizeCounts, totalPanicles),
            pw.SizedBox(height: 20),
            
            // Detailed Stats
            _buildDetailedStats(stats),
            pw.SizedBox(height: 20),
            
            // Footer
            _buildFooter(),
          ],
        ),
      );
      
      // Save PDF file
      return await _savePdfToFile(pdf, report);
      
    } catch (e) {
      print('❌ PDF generation error: $e');
      rethrow;
    }
  }

  // 2. Cover Page
  pw.Widget _buildCoverPage(Report report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(height: 50),
        pw.Text(
          'RICE PANICLE ANALYSIS REPORT',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 30),
        
        // Logo/Icon
        pw.Container(
          width: 100,
          height: 100,
          decoration: pw.BoxDecoration(
            color: PdfColors.green,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              '🌾',
              style: pw.TextStyle(fontSize: 40),
            ),
          ),
        ),
        pw.SizedBox(height: 30),
        
        pw.Text(
          'Report ID: ${report.reportId ?? report.id}',
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 10),
        
        pw.Text(
          'Generated: ${report.createdAt.toString()}',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey,
          ),
        ),
        pw.SizedBox(height: 40),
        
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // 3. Summary Section
  pw.Widget _buildSummarySection(Map<String, dynamic> stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SUMMARY',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 20),
        
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _summaryCard('Total Panicles', '${stats['total_panicles'] ?? 0}'),
            _summaryCard('Total Weight', '${stats['total_weight_kg'] ?? 0} kg'),
            _summaryCard('Yield/Hectare', '${stats['yield_per_hectare_kg'] ?? 0} kg'),
          ],
        ),
      ],
    );
  }

  pw.Container _summaryCard(String title, String value) {
    return pw.Container(
      width: 150,
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 4. Chart Section
  pw.Widget _buildChartSection(
    Map<String, dynamic> chartData, 
    Map<String, dynamic> sizeCounts,
  ) {
    final labels = List<String>.from(chartData['labels'] ?? []);
    final values = List<int>.from(chartData['values'] ?? []);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PANICLE SIZE DISTRIBUTION',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 20),
        
        // Bar Chart
        pw.Container(
          height: 200,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < labels.length; i++)
                pw.Expanded(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        height: values[i] * 5.0, // Scale factor
                        width: 40,
                        decoration: pw.BoxDecoration(
                          color: _getSizeColor(labels[i]),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        margin: pw.EdgeInsets.symmetric(horizontal: 10),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        labels[i],
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${values[i]}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Size Distribution
  pw.Widget _buildSizeDistribution(
    Map<String, dynamic> sizeCounts, 
    int totalPanicles,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SIZE-WISE ANALYSIS',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 20),
        
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'Size',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'Count',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'Percentage',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'Weight',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
              ],
            ),
            
            for (var entry in sizeCounts.entries)
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Row(
                      children: [
                        pw.Container(
                          width: 10,
                          height: 10,
                          decoration: pw.BoxDecoration(
                            color: _getSizeColor(entry.key),
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          entry.key.toUpperCase(),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text('${entry.value}'),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      totalPanicles > 0 
                        ? '${((entry.value / totalPanicles) * 100).toStringAsFixed(1)}%'
                        : '0%',
                    ),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(10),
                    child: pw.Text(
                      _calculateWeight(entry.key, entry.value),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // 6. Detailed Stats
  pw.Widget _buildDetailedStats(Map<String, dynamic> stats) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DETAILED STATISTICS',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 20),
        
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(2),
          },
          children: [
            _buildTableRow('Analysis Timestamp', stats['analysis_timestamp'] ?? ''),
            _buildTableRow('Total Panicles', '${stats['total_panicles'] ?? 0}'),
            _buildTableRow('Total Weight', '${stats['total_weight_kg'] ?? 0} kg'),
            _buildTableRow('Yield per Hectare', '${stats['yield_per_hectare_kg'] ?? 0} kg'),
            _buildTableRow('Processing Time', 
              '${(stats['total_processing_time'] ?? 0).toStringAsFixed(2)} seconds'),
            _buildTableRow('Small Panicles', '${stats['size_counts']?['small'] ?? 0}'),
            _buildTableRow('Medium Panicles', '${stats['size_counts']?['medium'] ?? 0}'),
            _buildTableRow('Large Panicles', '${stats['size_counts']?['large'] ?? 0}'),
          ],
        ),
      ],
    );
  }

  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(10),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(10),
          child: pw.Text(value),
        ),
      ],
    );
  }

  // 7. Footer
  pw.Widget _buildFooter() {
    return pw.Container(
      padding: pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Rice Panicle Analyzer',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'This report was generated automatically by the Rice Panicle Analysis System.',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated on: ${DateTime.now().toString()}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 8. Helper Methods
  PdfColor _getSizeColor(String size) {
    switch (size.toLowerCase()) {
      case 'small':
        return PdfColors.green;
      case 'medium':
        return PdfColors.blue;
      case 'large':
        return PdfColors.orange;
      default:
        return PdfColors.grey;
    }
  }

  String _calculateWeight(String size, int count) {
    // Average weights (adjust as needed)
    final avgWeights = {
      'small': 0.002,
      'medium': 0.004,
      'large': 0.006,
    };
    
    final weight = avgWeights[size.toLowerCase()] ?? 0.0;
    return '${(weight * count).toStringAsFixed(3)} kg';
  }

  // 9. Save PDF to File
  Future<File> _savePdfToFile(pw.Document pdf, Report report) async {
    try {
      final bytes = await pdf.save();
      
      // Get directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Rice_Panicle_Report_${report.reportId ?? report.id}.pdf';
      final filePath = '${directory.path}/$fileName';
      
      // Save file
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      print('✅ PDF saved: $filePath');
      return file;
    } catch (e) {
      print('❌ Error saving PDF: $e');
      rethrow;
    }
  }

  // 10. Share PDF
  Future<void> sharePdf(File pdfFile) async {
    try {
      await Share.shareXFiles([XFile(pdfFile.path)],
        text: 'Rice Panicle Analysis Report',
        subject: 'Panicle Analysis Report',
      );
    } catch (e) {
      print('❌ Error sharing PDF: $e');
      rethrow;
    }
  }

  // 11. Preview PDF
  Future<void> previewPdf(File pdfFile, BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (format) => pdfFile.readAsBytes(),
    );
  }
}