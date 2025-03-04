import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../navigation/guest_navigation.dart';
import '../../navigation/member_navigation.dart';
import '../common/analysis_result_screen.dart';

class GalleryScreen extends StatefulWidget {
  final bool isMember;

  const GalleryScreen({super.key, required this.isMember});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  File? _selectedImage; // เก็บรูปที่เลือก

  // ฟังก์ชันเปิดแกลอรี่ให้เลือกภาพ
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      // จำลองการวิเคราะห์โรคและไปหน้าแสดงผลลัพธ์
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imagePath: pickedFile.path,
              diseaseName: "Leaf Spot Disease", // จำลองผลลัพธ์
              confidence: 92.5, // จำลองค่าความมั่นใจ
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ตรวจสอบ arguments ก่อนใช้งาน
    final args = ModalRoute.of(context)?.settings.arguments;
    final bool isMember =
        (args is Map<String, dynamic> && args.containsKey('isMember'))
            ? args['isMember']
            : widget.isMember;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text("เลือกภาพจากแกลอรี่"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMember
          ? const MemberNavigation(selectedIndex: 1)
          : const GuestNavigation(
              selectedIndex: 1), // ✅ แสดง Navigation ตามค่า isMember
    );
  }
}
