import 'package:flutter/material.dart';
import '../../../widgets/app_bar.dart';
import '../../db.dart'; // เพิ่ม import DatabaseHelper
import '../../widgets/post_card_member.dart';

class HomeScreenMember extends StatefulWidget {
  // เปลี่ยนเป็น StatefulWidget
  const HomeScreenMember({super.key});

  @override
  State<HomeScreenMember> createState() => _HomeScreenMemberState();
}

class _HomeScreenMemberState extends State<HomeScreenMember> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: const CustomAppBar(title: "TOMATO CARE"),
      body: Column(
        children: [
          // ✅ ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle:
                    const TextStyle(fontFamily: 'Questrial'), // ✅ ใช้ Questrial
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

          // ✅ รายการโพสต์ (สไลด์ได้)
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: StreamBuilder<List<Map<String, dynamic>>>(
                // ระบุ type ให้ชัดเจน
                stream: DatabaseHelper.instance.getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.post_add_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              fontFamily: 'Questrial',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start sharing your content now!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                              fontFamily: 'Questrial',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final posts = snapshot.data!;
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCardMember(post: posts[index]);
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
