import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/app_bar.dart';
import '../common/analysis_result_screen.dart';

class GalleryScreenMember extends StatefulWidget {
  const GalleryScreenMember({super.key});

  @override
  State<GalleryScreenMember> createState() => _GalleryScreenMemberState();
}

class _GalleryScreenMemberState extends State<GalleryScreenMember> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted) return;

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      final context = this.context;
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imagePath: pickedFile.path,
              diseaseName: "Leaf Spot Disease",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Gallery"),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22512F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
