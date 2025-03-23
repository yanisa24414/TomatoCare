import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../db.dart'; // เพิ่ม import

class PostCardGuest extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCardGuest({super.key, required this.post});

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString).toLocal();
    return timeago.format(date);
  }

  String _formatCommentTime(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post['user']?['profile_image_url'] != null
                  ? NetworkImage(post['user']['profile_image_url'])
                  : null,
              child: post['user']?['profile_image_url'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(post['user']?['username'] ?? 'Unknown'),
            subtitle: Text(_formatTimeAgo(post['created_at'])),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post['content'] ?? ''),
          ),

          // แก้ไขส่วนแสดงรูปภาพ
          if (post['image_urls'] != null &&
              (post['image_urls'] as List).isNotEmpty)
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: (post['image_urls'] as List).length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      post['image_urls'][index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 40, color: Colors.red),
                              SizedBox(height: 8),
                              Text('Could not load image',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

          // Divider
          const Divider(),

          // Like count and login prompt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.grey),
                const SizedBox(width: 8),
                Text('${post['likes_count'] ?? 0} likes'),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, color: Colors.grey),
              ],
            ),
          ),

          // Comments section
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: DatabaseHelper.instance.getCommentsStream(post['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  ...snapshot.data!.map((comment) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: comment['user']
                                    ?['profile_image_url'] !=
                                null
                            ? NetworkImage(comment['user']['profile_image_url'])
                            : null,
                        child: comment['user']?['profile_image_url'] == null
                            ? const Icon(Icons.person, size: 20)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            comment['user']?['username'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatCommentTime(comment['created_at']),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(comment['content']),
                    );
                  }),

                  // Login prompt for commenting
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'Sign in to comment and interact with posts',
                        style: TextStyle(
                          color: Color(0xFF7D2424),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
