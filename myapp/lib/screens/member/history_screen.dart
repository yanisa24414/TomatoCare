import 'package:flutter/material.dart';
import '../../db.dart';

import 'package:timeago/timeago.dart' as timeago;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // เปลี่ยนจาก 3 เป็น 2
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back, color: Colors.white), // เพิ่มสีขาว
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true, // ทำให้ title อยู่ตรงกลาง
          title: const Text(
            'History',
            style: TextStyle(
              fontFamily: 'Questrial',
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          backgroundColor: const Color(0xFF7D2424),
          bottom: const TabBar(
            labelStyle: TextStyle(
              fontFamily: 'Questrial',
              fontSize: 16,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Questrial',
              fontSize: 16,
            ),
            labelColor: Colors.white, // สีตัวอักษรแท็บที่เลือก
            unselectedLabelColor:
                Colors.white70, // สีตัวอักษรแท็บที่ไม่ได้เลือก
            tabs: [
              Tab(text: 'Scans'),
              Tab(text: 'Posts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScansTab(),
            _buildPostsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildScansTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseHelper.instance.getUserScans(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error in scans tab: ${snapshot.error}');
          return const Center(
            child: Text(
              'Error loading scans',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Questrial',
                color: Colors.grey,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final scans = snapshot.data!;
        if (scans.isEmpty) {
          return const Center(
            child: Text(
              'No scans history yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Questrial',
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            return ListTile(
              leading: scan['image_url'] != null
                  ? Image.network(
                      scan['image_url'],
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.image_not_supported),
              title: Text(scan['disease_name'] ?? 'Unknown disease'),
              subtitle: Text(timeago.format(DateTime.parse(
                  scan['created_at'] ?? DateTime.now().toString()))),
              trailing: Text(scan['confidence'] != null
                  ? '${(scan['confidence'] * 100).toStringAsFixed(1)}%'
                  : 'N/A'),
            );
          },
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseHelper.instance.getUserPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error in posts tab: ${snapshot.error}');
          return const Center(
            child: Text(
              'Error loading posts',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Questrial',
                color: Colors.grey,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return const Center(
            child: Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Questrial',
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final List<String> imageUrls =
                List<String>.from(post['image_urls'] ?? []);

            return Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      post['content'] ?? 'No content',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Questrial',
                      ),
                    ),
                  ),
                  if (imageUrls.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, imageIndex) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrls[imageIndex],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Text(
                          timeago.format(
                            DateTime.parse(post['created_at'] ??
                                DateTime.now().toString()),
                          ),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontFamily: 'Questrial',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
