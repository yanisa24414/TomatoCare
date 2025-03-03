import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ✅ Import AuthService

class PostCard extends StatefulWidget {
  final String username;
  final String postText;
  final String? imagePath;

  const PostCard({
    super.key,
    required this.username,
    required this.postText,
    this.imagePath,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isMember = false; // ค่าเริ่มต้นเป็น Guest

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    bool status =
        await AuthService.isMember(); // ✅ เช็คว่าผู้ใช้เป็น Member ไหม
    setState(() {
      isMember = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF7D2424),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🟢 ชื่อผู้ใช้
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.username,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // 🖼 รูปภาพ (ถ้ามี)
          if (widget.imagePath != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(widget.imagePath!, fit: BoxFit.cover),
              ),
            ),

          // ✍️ ข้อความโพสต์
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.postText,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          // 💬 ช่องคอมเมนต์ (Guest จะเด้งแจ้งเตือน)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                if (!isMember) {
                  _showLoginAlert(context); // 🔴 แจ้งเตือนถ้าเป็น Guest
                }
              },
              child: TextField(
                enabled: isMember, // ✅ ปิดการพิมพ์ถ้าเป็น Guest
                decoration: InputDecoration(
                  hintText:
                      isMember ? "Write a comment..." : "Login to comment...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔴 แจ้งเตือนให้ล็อกอินก่อนคอมเมนต์
  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFE4C4), // ✅ พื้นหลังสีเนื้อ
          title: const Text("Notice",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Please log in as a member to comment."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), // ✅ สีปุ่มเขียวเข้ม
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login'); // ✅ ไปหน้า Login
              },
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
