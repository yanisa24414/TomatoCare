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
  List<File> _selectedImages = []; // เปลี่ยนจาก File? เป็น List<File>

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1200, // เพิ่มขนาดรูปให้ใหญ่ขึ้น
      maxHeight: 1200,
      imageQuality: 85, // ปรับคุณภาพรูป
    );

    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<void> _createPost() async {
    try {
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final user = DatabaseHelper.instance.client.auth.currentUser;
        if (user != null) {
          // อัพโหลดรูปทีละรูป
          for (var image in _selectedImages) {
            final fileExt = image.path.split('.').last.toLowerCase();
            final fileName =
                'post_${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.$fileExt';

            await DatabaseHelper.instance.client.storage
                .from('post-images')
                .upload(fileName, image);

            final imageUrl = DatabaseHelper.instance.client.storage
                .from('post-images')
                .getPublicUrl(fileName);

            imageUrls.add(imageUrl);
          }
        }
      }

      // สร้างโพสต์พร้อมรูปภาพหลายรูป
      await DatabaseHelper.instance.createPost(
        content: _contentController.text.trim(),
        imageUrls: imageUrls, // เปลี่ยนเป็นส่ง array ของ URLs
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
                    color: Colors.black.withOpacity(0.1),
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
                                borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.all(16),
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
                                fontSize: 16,
                                fontFamily: 'Questrial',
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22512F),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                fontSize: 16,
                                fontFamily: 'Questrial',
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7D2424),
                              padding: const EdgeInsets.symmetric(vertical: 15),
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
