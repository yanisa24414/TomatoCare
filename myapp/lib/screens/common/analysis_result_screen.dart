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
    final bool hasValidDiseaseInfo = diseaseInfo != null &&
        diseaseInfo!['name'] != null &&
        diseaseInfo!['name'] != 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analysis Result',
          style: TextStyle(fontFamily: 'Questrial', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7D2424),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFDF6E3),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // โซนรูปภาพ
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // โซนผลการวิเคราะห์
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อโรค
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7D2424).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            hasValidDiseaseInfo
                                ? Icons.local_hospital
                                : Icons.warning,
                            color: const Color(0xFF7D2424),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diagnosis',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  fontFamily: 'Questrial',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasValidDiseaseInfo
                                    ? diseaseInfo!['name']
                                    : 'Analysis not available',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7D2424),
                                  fontFamily: 'Questrial',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // รายละเอียดโรค
                    _buildDetailSection(
                      title: 'Description',
                      content: diseaseInfo?['description'],
                      icon: Icons.description,
                    ),
                    _buildDetailSection(
                      title: 'Symptoms',
                      content: diseaseInfo?['symptoms'],
                      icon: Icons.sick,
                    ),
                    _buildDetailSection(
                      title: 'Treatment',
                      content: diseaseInfo?['treatment'],
                      icon: Icons.medical_services,
                    ),
                    _buildDetailSection(
                      title: 'Prevention',
                      content: diseaseInfo?['prevention'],
                      icon: Icons.health_and_safety,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String? content,
    required IconData icon,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF7D2424)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7D2424),
            fontFamily: 'Questrial',
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontFamily: 'Questrial',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
