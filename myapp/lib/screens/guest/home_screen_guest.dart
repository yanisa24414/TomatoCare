import 'package:flutter/material.dart';
import '../../../navigation/guest_navigation.dart';

class HomeScreenGuest extends StatelessWidget {
  const HomeScreenGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF22512F),
        title: const Text(
          "TOMATO CARE",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // รายการโพสต์ (สไลด์ได้)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: const [
                PostCard(
                  username: "SomSri K.",
                  postText: "โรคนี้เกิดขึ้นบ่อยไหมคะ",
                  imagePath: "assets/leaf1.jpg",
                ),
                PostCard(
                  username: "Poom V.",
                  postText: "มีใครมีแหล่งขายปุ๋ยและยารักษาโรคที่ครบวงจรไหมครับ",
                  imagePath: null,
                ),
                PostCard(
                  username: "Nui T.",
                  postText: "อยากรู้ว่ามีวิธีป้องกันโรคพวกนี้ไหม",
                  imagePath: null,
                ),
                PostCard(
                  username: "Arthit B.",
                  postText:
                      "ต้นมะเขือเทศที่บ้านเริ่มเป็นแบบนี้ มีวิธีแก้ไขไหม?",
                  imagePath: "assets/leaf2.jpg",
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const GuestNavigation(selectedIndex: 0),
    );
  }
}

class PostCard extends StatelessWidget {
  final String username;
  final String postText;
  final String? imagePath; // ใช้ ? เพื่อรองรับกรณีไม่มีรูป

  const PostCard({
    super.key,
    required this.username,
    required this.postText,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF7D2424),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัวของโพสต์
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              username,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // แสดงรูปภาพเฉพาะเมื่อ imagePath ไม่เป็น null และจัดให้อยู่ตรงกลาง
          if (imagePath != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10), // ขอบด้านข้าง
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // กำหนดอัตราส่วนให้ดูดี
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.cover, // ปรับให้รูปเต็มพื้นที่
                    ),
                  ),
                ),
              ),
            ),

          // ข้อความโพสต์
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              postText,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),

          // ช่องคอมเมนต์
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Comment...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
