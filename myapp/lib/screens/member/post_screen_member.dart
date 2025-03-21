import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../../db.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostScreenMember extends StatefulWidget {
  const PostScreenMember({super.key});

  @override
  State<PostScreenMember> createState() => _PostScreenMemberState();
}

class _PostScreenMemberState extends State<PostScreenMember> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final user = DatabaseHelper.instance.client.auth.currentUser;
        if (user != null) {
          final fileExt = _selectedImage!.path.split('.').last.toLowerCase();
          final fileName =
              'post_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

          print('Uploading image: $fileName'); // Debug log

          // แก้ไขการอัพโหลดรูปภาพ โดยใช้ upload แทน uploadBinary
          await DatabaseHelper.instance.client.storage
              .from('post-images')
              .upload(
                fileName,
                _selectedImage!,
              );

          await Future.delayed(const Duration(seconds: 2));

          // สร้าง public URL
          imageUrl = DatabaseHelper.instance.client.storage
              .from('post-images')
              .getPublicUrl(fileName);

          print('Generated URL: $imageUrl'); // Debug log
        }
      }

      // สร้างโพสต์
      await DatabaseHelper.instance.createPost(
        content: _contentController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      // แสดง SnackBar แจ้งสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      // กลับไปหน้า home_screen_member
      Navigator.pushReplacementNamed(context, '/member');
    } catch (e) {
      print('Error in _createPost: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Create Post"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text Input
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Image Preview
            if (_selectedImage != null)
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                // Add Image Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22512F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Post Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createPost,
                    icon: const Icon(Icons.send),
                    label: const Text('Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D2424),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
