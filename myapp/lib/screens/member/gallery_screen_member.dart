import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/app_bar.dart';
import '../common/analysis_result_screen.dart';
import '../../db.dart'; // เพิ่ม import นี้
import 'package:supabase_flutter/supabase_flutter.dart'; // เพิ่ม import
import 'package:path_provider/path_provider.dart'; // เพิ่ม import นี้

class GalleryScreenMember extends StatefulWidget {
  const GalleryScreenMember({super.key});

  @override
  State<GalleryScreenMember> createState() => _GalleryScreenMemberState();
}

class _GalleryScreenMemberState extends State<GalleryScreenMember> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1200,
        maxWidth: 1200,
      );

      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));

        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // 1. วิเคราะห์รูปด้วยโมเดล
        final predictions =
            await DatabaseHelper.instance.analyzeImage(File(pickedFile.path));

        // 2. หาโรคที่มีความน่าจะเป็นสูงสุด
        final topDisease =
            predictions.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        // 3. ดึงข้อมูลโรคจาก Supabase diseases table
        final diseaseInfo =
            await DatabaseHelper.instance.getDiseaseInfo(topDisease);

        if (!mounted) return;
        Navigator.pop(context); // Hide loading

        // 4. แสดงผลการวิเคราะห์พร้อมข้อมูลโรค
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imagePath: pickedFile.path,
              predictions: predictions,
              diseaseInfo: diseaseInfo,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Gallery"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((255 * 0.2).toInt()),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 80,
                          color: Color(0xFF7D2424),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Select an image to analyze",
                          style: TextStyle(
                            color: Color(0xFF7D2424),
                            fontSize: 18,
                            fontFamily: 'Questrial',
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D2424),
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.photo_library, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Choose from Gallery",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Questrial',
                      color: Colors.white,
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
