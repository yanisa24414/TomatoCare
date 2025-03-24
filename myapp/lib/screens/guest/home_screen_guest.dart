import 'package:flutter/material.dart';
import '../../../widgets/app_bar.dart';
import '../../db.dart'; // เพิ่ม import DatabaseHelper
import '../../widgets/post_card_guest.dart';

class HomeScreenGuest extends StatefulWidget {
  // เปลี่ยนเป็น StatefulWidget
  const HomeScreenGuest({super.key});

  @override
  State<HomeScreenGuest> createState() => _HomeScreenGuestState();
}

class _HomeScreenGuestState extends State<HomeScreenGuest> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Map<String, dynamic>>> _postsStream =
      DatabaseHelper.instance.getPostsStream();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final searchTerm = _searchController.text.trim();
    setState(() {
      _postsStream = searchTerm.isEmpty
          ? DatabaseHelper.instance.getPostsStream()
          : DatabaseHelper.instance.searchPosts(searchTerm);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              controller: _searchController, // Add controller
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
                _onSearchChanged(); // Refresh search results
              },
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream:
                    _postsStream, // Use _postsStream instead of getPostsStream()
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
                            Icons.article_outlined,
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
                            'Stay tuned for upcoming posts!',
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
