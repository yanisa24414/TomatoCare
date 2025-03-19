import 'dart:io';
import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String imagePath;
  final String diseaseName;

  const AnalysisResultScreen({
    super.key,
    required this.imagePath,
    required this.diseaseName,
  });

  String _getDiseaseDescription() {
    // Add disease descriptions based on the disease name
    switch (diseaseName) {
      case "Leaf Spot Disease":
        return "โรคใบจุด (Leaf Spot) เป็นโรคที่พบบ่อยในมะเขือเทศ สาเหตุเกิดจากเชื้อรา Septoria lycopersici "
            "อาการที่พบ:\n"
            "• จุดแผลสีน้ำตาลถึงเทาบนใบ\n"
            "• ขอบแผลมีสีเหลือง\n"
            "• ใบจะเหลืองและร่วง\n\n"
            "วิธีป้องกันและรักษา:\n"
            "• ฉีดพ่นสารป้องกันกำจัดเชื้อรา\n"
            "• หลีกเลี่ยงการให้น้ำที่ใบ\n"
            "• กำจัดใบที่เป็นโรคออก";
      default:
        return "ไม่พบข้อมูลโรคนี้ในระบบ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D2424),
        title: const Text(
          "Analysis Result",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Questrial',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Section
            Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
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

            // Result Card
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Disease Name Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7D2424),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Text(
                      diseaseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Questrial',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Disease Description
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _getDiseaseDescription(),
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontFamily: 'Questrial',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("ถ่ายภาพใหม่"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22512F),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save),
                      label: const Text("บันทึกผล"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7D2424),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
