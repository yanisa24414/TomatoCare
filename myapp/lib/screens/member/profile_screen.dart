import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../db.dart'; // เปลี่ยนเป็นใช้ Supabase DatabaseHelper

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _logger = Logger('ProfileScreen');
  Map<String, dynamic>? userData;
  final _usernameController = TextEditingController();
  File? _profileImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // ดึงข้อมูล user ปัจจุบันจาก Supabase
      final currentUser = DatabaseHelper.instance.client.auth.currentUser;

      if (currentUser != null) {
        // ดึงข้อมูลเพิ่มเติมจากตาราง users
        final userData = await DatabaseHelper.instance.client
            .from('users')
            .select()
            .eq('id', currentUser.id)
            .single();

        if (mounted) {
          setState(() {
            this.userData = userData;
            _usernameController.text = userData['username'] ?? '';
          });
        }
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      _logger.severe('Error loading user data', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _logger.severe('Error picking image: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot access gallery. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;

    try {
      final currentUser = DatabaseHelper.instance.client.auth.currentUser;
      if (currentUser == null) throw Exception('No user logged in');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // อัพเดทข้อมูลใน users table
      await DatabaseHelper.instance.client.from('users').update({
        'username': _usernameController.text.trim(),
      }).eq('id', currentUser.id);

      // ถ้ามีการเลือกรูปโปรไฟล์ใหม่
      if (_profileImage != null) {
        // อัพเดทรูปโปรไฟล์
        final imageUrl = await DatabaseHelper.instance.updateProfileImage(
          currentUser.id,
          _profileImage!,
        );

        if (imageUrl != null) {
          setState(() {
            userData?['profile_image_url'] = imageUrl;
          });
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // ปิด loading

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF7D2424),
        ),
      );

      await _loadUserData(); // โหลดข้อมูลใหม่
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFF7D2424)),
            SizedBox(width: 10),
            Text(
              'Reset Password',
              style: TextStyle(
                color: Color(0xFF7D2424),
                fontFamily: 'Questrial',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We will send a password reset link to your email:',
              style: TextStyle(
                fontFamily: 'Questrial',
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              userData?['email'] ?? '',
              style: TextStyle(
                fontFamily: 'Questrial',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7D2424),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Questrial',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await DatabaseHelper.instance.sendPasswordResetEmail(
                  userData?['email'],
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Password reset link has been sent to your email',
                    ),
                    backgroundColor: Color(0xFF22512F),
                    duration: Duration(seconds: 4),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D2424),
            ),
            child: Text(
              'Send Link',
              style: TextStyle(
                fontFamily: 'Questrial',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D2424),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Questrial',
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Add color
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: Colors.white, // Add color
            ),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFDF6E3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF22512F),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (userData?['profile_image_url'] != null
                            ? NetworkImage(userData!['profile_image_url'])
                            : null) as ImageProvider?,
                    child: (_profileImage == null &&
                            userData?['profile_image_url'] == null)
                        ? const Icon(Icons.person,
                            size: 80, color: Colors.white)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF22512F),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.person,
                      label: 'Username',
                      value: userData?['username'] ?? 'Loading...',
                      isEditable: true,
                      controller: _usernameController,
                      isEditing: _isEditing,
                    ),
                    const Divider(),
                    _buildInfoTile(
                      icon: Icons.email,
                      label: 'Email',
                      value: userData?['email'] ?? 'Loading...',
                      isEditable: false,
                    ),
                    const Divider(),
                    _buildInfoTile(
                      icon: Icons.calendar_today,
                      label: 'Member Since',
                      value: _formatDate(userData?['created_at']),
                      isEditable: false,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock_outline,
                          color: Color(0xFF22512F)),
                      title: const Text(
                        'Reset Password',
                        style: TextStyle(fontFamily: 'Questrial'),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showPasswordResetDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = false,
    TextEditingController? controller,
    bool isEditing = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF22512F), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Questrial',
                  ),
                ),
                if (isEditable && isEditing)
                  TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Questrial',
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Questrial',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Loading...';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
