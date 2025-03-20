import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/app_bar.dart';
import '../common/analysis_result_screen.dart';

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
                    color: Colors.grey.withOpacity(0.2),
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
