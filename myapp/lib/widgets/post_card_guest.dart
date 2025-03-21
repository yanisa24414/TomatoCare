import 'package:flutter/material.dart';

class PostCardGuest extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostCardGuest({Key? key, required this.post}) : super(key: key);

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
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
            subtitle: Text(_formatDate(post['created_at'])),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(post['content'] ?? ''),
          ),

          // Post image - แก้ไขส่วนนี้
          if (post['image_url'] != null)
            Container(
              width: double.infinity,
              height: 200,
              child: Image.network(
                post['image_url'],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Icon(Icons.error);
                },
              ),
            ),

          // Divider
          const Divider(),

          // Login prompt
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
      ),
    );
  }
}
