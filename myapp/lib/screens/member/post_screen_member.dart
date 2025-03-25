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
  final List<File> _selectedImages = []; // เปลี่ยนจาก File? เป็น List<File>

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1200, // เพิ่มขนาดรูปให้ใหญ่ขึ้น
      maxHeight: 1200,
      imageQuality: 85, // ปรับคุณภาพรูป
    );

    setState(() {
      _selectedImages.addAll(pickedFiles.map((xFile) => File(xFile.path)));
    });
  }

  Future<void> _createPost() async {
    try {
      // สร้างโพสต์พร้อมรูปภาพ
      await DatabaseHelper.instance.createPost(
        content: _contentController.text.trim(),
        images:
            _selectedImages, // เปลี่ยนจาก imageUrls เป็น images เพื่อให้ตรงกับ DatabaseHelper
      );

      if (!mounted) return;

      // แสดง SnackBar แจ้งสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      // กลับไปหน้า home_screen_member
      Navigator.pushReplacementNamed(context, '/member');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          const CustomAppBar(title: "Create Post"), // เปลี่ยนมาใช้ CustomAppBar
      backgroundColor: const Color(0xFFFDF6E3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ส่วนบนสำหรับ input
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Text Input
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _contentController,
                      maxLines: 5,
                      style: const TextStyle(
                        fontFamily: 'Questrial',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'Questrial',
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // แสดงรูปภาพที่เลือกแบบ grid
                  if (_selectedImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.white, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  // Buttons
                  Padding(
                    padding: const EdgeInsets.all(11),
                    child: Row(
                      children: [
                        // Add Image Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(
                              Icons.image,
                              size: 24,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Add Image',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Questrial',
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22512F),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Post Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _createPost,
                            icon: const Icon(
                              Icons.send,
                              size: 24,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Questrial',
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7D2424),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
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

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
