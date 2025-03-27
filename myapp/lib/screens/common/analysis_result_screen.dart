import 'dart:io';
import 'package:flutter/material.dart';
import '../../db.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // เพิ่ม import นี้

class AnalysisResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, double> predictions;
  final Map<String, dynamic>? diseaseInfo;

  const AnalysisResultScreen({
    required this.imagePath,
    required this.predictions,
    this.diseaseInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบข้อมูลโรค
    final bool hasValidDiseaseInfo = diseaseInfo != null &&
        diseaseInfo!['name'] != null &&
        diseaseInfo!['name'] != 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: const Color(0xFF7D2424),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงรูปที่วิเคราะห์
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(imagePath)),
            ),
            const SizedBox(height: 24),

            // แสดงชื่อโรคและความน่าจะเป็น
            Text(
              'Disease: ${hasValidDiseaseInfo ? diseaseInfo!['name'] : 'Analysis not available'}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    hasValidDiseaseInfo ? const Color(0xFF7D2424) : Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            // แสดงรายละเอียดโรค
            _buildSection('Description', diseaseInfo?['description']),
            _buildSection('Symptoms', diseaseInfo?['symptoms']),
            _buildSection('Treatment', diseaseInfo?['treatment']),
            _buildSection('Prevention', diseaseInfo?['prevention']),

            // แสดงความน่าจะเป็นของแต่ละโรค
            const SizedBox(height: 16),
            const Text(
              'Confidence Levels:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...predictions.entries
                .where((e) => e.value > 0.1)
                .map((e) => _buildProbabilityBar(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Questrial',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Questrial',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(String label, double probability) {
    // แสดงเฉพาะโรคที่มีความน่าจะเป็นมากกว่า 10%
    if (probability < 0.1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontFamily: 'Questrial'),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: probability,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              probability > 0.5 ? const Color(0xFF7D2424) : Colors.grey,
            ),
          ),
          Text(
            '${(probability * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontFamily: 'Questrial'),
          ),
        ],
      ),
    );
  }
}
