import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/app_bar.dart';
import '../common/analysis_result_screen.dart';
import '../../navigation/tab_navigation.dart';

class GalleryScreenGuest extends StatefulWidget {
  const GalleryScreenGuest({super.key});

  @override
  State<GalleryScreenGuest> createState() => _GalleryScreenGuestState();
}

class _GalleryScreenGuestState extends State<GalleryScreenGuest> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(
            imagePath: pickedFile.path,
            diseaseName: "Leaf Spot Disease",
            confidence: 92.5,
          ),
        ),
      );
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
                backgroundColor: const Color(0xFF7D2424),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TabNavigation(
        isMember: false,
        selectedIndex: 1,
        onTabPress: (index) => Navigator.pushReplacementNamed(
          context,
          [
            '/guest/home',
            '/guest/gallery',
            '/guest/camera',
            '/guest/settings'
          ][index],
        ),
      ),
    );
  }
}
