import 'package:flutter/material.dart';
import '../../../widgets/app_bar.dart';
import '../../db.dart'; // เพิ่ม import DatabaseHelper
import '../../widgets/post_card_guest.dart';

class HomeScreenGuest extends StatelessWidget {
  const HomeScreenGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: const CustomAppBar(title: "TOMATO CARE"),
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
            child: RefreshIndicator(
              onRefresh: () async {
                // เมื่อดึงลงมาจะ reload หน้า
                // ไม่ต้องทำอะไรเพิ่มเติมเพราะ StreamBuilder จะ reload เอง
              },
              child: StreamBuilder<List<Map<String, dynamic>>>(
                // ระบุ type ให้ชัดเจน
                stream: DatabaseHelper.instance.getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final posts = snapshot.data!;
                  return ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // เพิ่มบรรทัดนี้
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCardGuest(post: post);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
