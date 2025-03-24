import 'package:flutter/material.dart';
import '../db.dart'; // เพิ่ม import
import 'package:timeago/timeago.dart' as timeago;
import 'package:logging/logging.dart';

// เปลี่ยนจาก StatelessWidget เป็น StatefulWidget
class PostCardMember extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCardMember({super.key, required this.post});

  @override
  State<PostCardMember> createState() => _PostCardMemberState();
}

class _PostCardMemberState extends State<PostCardMember> {
  static final _log = Logger('PostCardMember');

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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.comment, color: Color(0xFF7D2424), size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Add Comment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7D2424),
                      fontFamily: 'Questrial',
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                maxLines: 3,
                maxLength: 500,
                style: const TextStyle(
                  fontFamily: 'Questrial',
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: 'Questrial',
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFF7D2424), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontFamily: 'Questrial'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (commentController.text.trim().isNotEmpty) {
                        await DatabaseHelper.instance.addComment(
                          postId: widget.post['id'],
                          content: commentController.text.trim(),
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D2424),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Post Comment',
                      style: TextStyle(
                        fontFamily: 'Questrial',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFF7D2424), size: 28),
            SizedBox(width: 10),
            Text(
              'Delete Post?',
              style: TextStyle(
                color: Color(0xFF7D2424),
                fontFamily: 'Questrial',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Questrial',
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'Questrial',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DatabaseHelper.instance.deletePost(widget.post['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post deleted successfully'),
                    backgroundColor: Color(0xFF22512F),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete post: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D2424),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Questrial',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _log.fine('Building post card: ${widget.post}'); // แทน print ด้วย _log.fine
    _log.fine('Image URLs: ${widget.post['image_urls']}'); // Debug log

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
            trailing: widget.post['user_id'] ==
                    DatabaseHelper.instance.client.auth.currentUser?.id
                ? IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Color(0xFF7D2424)),
                    onPressed: _showDeleteDialog,
                  )
                : null,
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
                        _log.warning(
                            'Error loading image: $error'); // แทน print
                        _log.warning(
                            'Image URL: ${widget.post['image_urls'][index]}');
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

          // เพิ่มแถวปุ่ม Like และ Comment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Like button
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _handleLike,
                ),
                Text('$_likesCount likes'),
                const SizedBox(width: 16),
                // Comment button
                IconButton(
                  icon: const Icon(
                    Icons.comment_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () => _showCommentDialog(context),
                ),
              ],
            ),
          ),

          // Comments section
          StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                DatabaseHelper.instance.getCommentsStream(widget.post['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: snapshot.data!.map((comment) {
                  final isCommentOwner = comment['user_id'] ==
                      DatabaseHelper.instance.client.auth.currentUser?.id;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: comment['user']?['profile_image_url'] !=
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
                        Text(_formatCommentTime(comment['created_at'])),
                      ],
                    ),
                    subtitle: Text(comment['content']),
                    trailing: isCommentOwner
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFF7D2424),
                              size: 20,
                            ),
                            onPressed: () async {
                              // แสดง dialog ยืนยันการลบแบบใหม่
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Color(0xFF7D2424),
                                        size: 28,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Delete Comment?',
                                        style: TextStyle(
                                          color: Color(0xFF7D2424),
                                          fontFamily: 'Questrial',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete this comment?',
                                    style: TextStyle(
                                      fontFamily: 'Questrial',
                                      fontSize: 16,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontFamily: 'Questrial',
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF7D2424),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Questrial',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  actionsPadding: EdgeInsets.all(20),
                                ),
                              );

                              if (confirmed == true) {
                                try {
                                  await DatabaseHelper.instance
                                      .deleteComment(comment['id']);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Comment deleted successfully',
                                        style:
                                            TextStyle(fontFamily: 'Questrial'),
                                      ),
                                      backgroundColor: Color(0xFF22512F),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to delete comment: $e',
                                        style:
                                            TextStyle(fontFamily: 'Questrial'),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          )
                        : null,
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
