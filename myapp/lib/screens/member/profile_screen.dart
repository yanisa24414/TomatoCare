import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import 'package:logging/logging.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:permission_handler/permission_handler.dart';

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
      // Get current user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        // Get user data by ID
        final user = await DatabaseHelper.instance.getUserById(userId);
        if (user != null) {
          setState(() {
            userData = user;
            _usernameController.text = user['username'];
          });
        } else {
          throw Exception('User not found');
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
      if (userData == null || userData!['id'] == null) {
        throw Exception('Invalid user data');
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await DatabaseHelper.instance.updateUser(
        userId: userData!['id'],
        username: _usernameController.text.trim(),
        profileImagePath: _profileImage?.path,
      );

      if (!mounted) return;
      Navigator.pop(context); // ปิด loading

      setState(() {
        userData!['username'] = _usernameController.text.trim();
        if (_profileImage != null) {
          userData!['profile_image'] = _profileImage!.path;
        }
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF7D2424),
        ),
      );

      await _loadUserData();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // ปิด loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                        : null,
                    child: _profileImage == null
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
