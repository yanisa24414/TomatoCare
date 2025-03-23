import 'dart:io';
import 'package:flutter/material.dart';
import '../../db.dart'; // เพิ่ม import

class AnalysisResultScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, double> predictions;

  const AnalysisResultScreen({
    super.key,
    required this.imagePath,
    required this.predictions,
  });

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  Map<String, dynamic>? diseaseInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiseaseInfo();
  }

  Future<void> _loadDiseaseInfo() async {
    try {
      // หา disease ที่มีความน่าจะเป็นสูงสุด
      String topDisease = widget.predictions.entries.reduce((a, b) {
        print(
            'Comparing: ${a.key}: ${a.value} vs ${b.key}: ${b.value}'); // Debug log
        return a.value > b.value ? a : b;
      }).key;

      print('Top disease detected: $topDisease'); // Debug log
      print('All predictions: ${widget.predictions}'); // Debug log

      // ดึงข้อมูลโรคจาก Supabase
      final info = await DatabaseHelper.instance.getDiseaseInfo(topDisease);
      print('Disease info from database: $info'); // Debug log

      if (mounted) {
        setState(() {
          diseaseInfo = info;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _loadDiseaseInfo: $e'); // Debug log
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading disease information: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(widget.imagePath)),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (diseaseInfo != null) ...[
              Text(
                'Diagnosis: ${diseaseInfo!['name']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D2424),
                  fontFamily: 'Questrial',
                ),
              ),
              const SizedBox(height: 16),
              _buildSection('Description', diseaseInfo!['description']),
              _buildSection('Symptoms', diseaseInfo!['symptoms']),
              _buildSection('Treatment', diseaseInfo!['treatment']),
              _buildSection('Prevention', diseaseInfo!['prevention']),
              const SizedBox(height: 16),
              const Text(
                'Confidence Levels:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Questrial',
                ),
              ),
              ...widget.predictions.entries
                  .map((e) => _buildProbabilityBar(e.key, e.value)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
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
            content,
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
