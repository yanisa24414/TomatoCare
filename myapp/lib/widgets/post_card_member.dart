import 'package:flutter/material.dart';
import '../db.dart'; // เพิ่ม import

class PostCardMember extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCardMember({Key? key, required this.post}) : super(key: key);

  // เพิ่มฟังก์ชัน _formatDate
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleLike() {
    // Handle like action
  }

  void _showCommentDialog(BuildContext context) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Comment'),
        content: TextField(
          controller: commentController,
          decoration: InputDecoration(hintText: 'Write a comment...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentController.text.trim().isNotEmpty) {
                await DatabaseHelper.instance.addComment(
                  postId: post['id'],
                  content: commentController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Comment'),
          ),
        ],
      ),
    );
  }

  void _handleShare() {
    // Handle share action
  }

  @override
  Widget build(BuildContext context) {
    print('Post data: $post'); // Debug log
    print('Image URL: ${post['image_url']}'); // Debug log

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post['user']?['profile_image_url'] != null
                  ? NetworkImage(post['user']['profile_image_url'])
                  : null,
              child: post['user']?['profile_image_url'] == null
                  ? Icon(Icons.person)
                  : null,
            ),
            title: Text(post['user']?['username'] ?? 'Unknown'),
            subtitle: Text(_formatDate(post['created_at'])),
          ),
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post['content'] ?? ''),
          ),

          // แก้ไขส่วนแสดงรูปภาพ
          if (post['image_url'] != null &&
              post['image_url'].toString().isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              child: Image.network(
                post['image_url'],
                fit: BoxFit.cover,
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
                  print('Image URL: ${post['image_url']}');
                  return Container(
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 40, color: Colors.red),
                        SizedBox(height: 8),
                        Text(
                          'Could not load image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Comments section
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: DatabaseHelper.instance.getCommentsStream(post['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return Column(
                children: snapshot.data!.map((comment) {
                  return ListTile(
                    title: Text(comment['content']),
                    subtitle: Text(comment['user']['username']),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
