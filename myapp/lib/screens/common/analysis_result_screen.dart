import 'dart:io';
import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String imagePath;
  final String diseaseName;
  final double confidence;

  const AnalysisResultScreen({
    super.key,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D2424),
        title: const Text(
          "Analysis Result",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.file(
              File(imagePath),
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              "Disease: $diseaseName",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Confidence: ${confidence.toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("กลับไปเลือกใหม่"),
            ),
          ],
        ),
      ),
    );
  }
}
