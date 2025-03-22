import 'package:flutter/material.dart';
import '../db.dart'; // เพิ่ม import
import 'package:timeago/timeago.dart' as timeago;

// เปลี่ยนจาก StatelessWidget เป็น StatefulWidget
class PostCardMember extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCardMember({Key? key, required this.post}) : super(key: key);

  @override
  State<PostCardMember> createState() => _PostCardMemberState();
}

class _PostCardMemberState extends State<PostCardMember> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post['is_liked'] ?? false;
    _likesCount = widget.post['likes_count'] ?? 0;
  }

  // เพิ่มฟังก์ชัน _formatDate
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

  Future<void> _handleLike() async {
    // อัพเดต UI ทันที
    setState(() {
      if (_isLiked) {
        _likesCount--;
      } else {
        _likesCount++;
      }
      _isLiked = !_isLiked;
    });

    try {
      // อัพเดตข้อมูลใน database
      await DatabaseHelper.instance.toggleLike(widget.post['id']);
    } catch (e) {
      // ถ้าเกิด error ให้ revert การเปลี่ยนแปลง
      setState(() {
        if (_isLiked) {
          _likesCount--;
        } else {
          _likesCount++;
        }
        _isLiked = !_isLiked;
      });
      // แสดง error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update like: $e')),
        );
      }
    }
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
                  postId: widget.post['id'],
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
    print('Post data: ${widget.post}'); // Debug log
    print('Image URLs: ${widget.post['image_urls']}'); // Debug log

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: widget.post['user']?['profile_image_url'] != null
                  ? NetworkImage(widget.post['user']['profile_image_url'])
                  : null,
              child: widget.post['user']?['profile_image_url'] == null
                  ? Icon(Icons.person)
                  : null,
            ),
            title: Text(widget.post['user']?['username'] ?? 'Unknown'),
            subtitle: Text(_formatTimeAgo(widget.post['created_at'])),
          ),
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(widget.post['content'] ?? ''),
          ),

          // แก้ไขส่วนแสดงรูปภาพ
          if (widget.post['image_urls'] != null &&
              (widget.post['image_urls'] as List).isNotEmpty)
            SizedBox(
              height: 300, // เพิ่มความสูง
              child: PageView.builder(
                // เปลี่ยนจาก ListView เป็น PageView
                itemCount: (widget.post['image_urls'] as List).length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.post['image_urls'][index],
                      fit: BoxFit.contain, // เปลี่ยนจาก cover เป็น contain
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
                        print('Image URL: ${widget.post['image_urls'][index]}');
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

          // Like button and count with optimistic update
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _handleLike,
                ),
                Text('$_likesCount likes'),
              ],
            ),
          ),

          // Comments section
          StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                DatabaseHelper.instance.getCommentsStream(widget.post['id']),
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
