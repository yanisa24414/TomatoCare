import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // เพิ่มบรรทัดนี้

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  late final SupabaseClient client;
  DateTime? _lastRegistrationAttempt;

  // Private constructor
  DatabaseHelper._internal() {
    client = Supabase.instance.client;
  }

  Future<bool> testConnection() async {
    try {
      await client.from('users').select().limit(1);
      print('Database connection successful');
      return true;
    } catch (e) {
      print('Database connection failed: $e');
      return false;
    }
  }

  // Register a new user
  Future<void> registerUser({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Check if enough time has passed since last attempt
      if (_lastRegistrationAttempt != null) {
        final timeDiff = DateTime.now().difference(_lastRegistrationAttempt!);
        if (timeDiff.inSeconds < 30) {
          throw 'Please wait ${30 - timeDiff.inSeconds} seconds before trying again';
        }
      }

      _lastRegistrationAttempt = DateTime.now();
      print("Starting registration for email: $email");

      // First create auth user
      final AuthResponse auth = await client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
        emailRedirectTo: null, // เพิ่มบรรทัดนี้แทน options
      );

      if (auth.user == null) {
        throw 'Registration failed: No user data received';
      }

      print("Auth user created with ID: ${auth.user!.id}");

      // Then store additional user data
      await client.from('users').insert({
        'id': auth.user!.id,
        'email': email,
        'username': username,
      }); // Remove .execute()

      print("User data inserted successfully");
    } catch (e, stackTrace) {
      print("Detailed error: $e");
      print("Stack trace: $stackTrace");

      if (e.toString().contains('over_email_send_rate_limit')) {
        throw 'Please wait 30 seconds before trying to register again';
      } else if (e.toString().contains('User already registered')) {
        throw 'This email is already registered';
      } else {
        throw 'Registration failed: ${e.toString()}';
      }
    }
  }

  // แก้ไข login method
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print("Attempting login for email: $email");

      // Try to sign in with Supabase Auth
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Check if we got a valid user and session
      if (response.user != null && response.session != null) {
        print("Auth successful, getting user data");

        // Get user data from our users table
        final userData = await client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        print("User data retrieved: $userData");

        // Store session
        await client.auth.setSession(response.session!.refreshToken!);

        return response.user;
      }

      print("Login failed - no user data or session");
      return null;
    } catch (e) {
      print("Login error: $e");
      if (e.toString().contains('Invalid login credentials')) {
        throw 'Invalid email or password';
      } else if (e.toString().contains('not found')) {
        throw 'User not found';
      } else {
        throw 'Login failed: Please try again';
      }
    }
  }

  // Query all users (for debugging)
  Future<List<Map<String, dynamic>>> queryUsers() async {
    final response = await client.from('users').select();
    return response;
  }

  // เพิ่ม method สำหรับอัพเดทรูปโปรไฟล์
  Future<String?> updateProfileImage(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/profile.$fileExt';

      // เปลี่ยนเป็นใช้ bytes แทน File
      final fileBytes = await imageFile.readAsBytes();

      // อัพโหลดไฟล์ไปที่ storage
      await client.storage.from('avatars').uploadBinary(
            fileName,
            fileBytes,
            fileOptions:
                const FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      // รอสักครู่ให้ไฟล์อัพโหลดเสร็จ
      await Future.delayed(const Duration(seconds: 1));

      // สร้าง public URL
      final imageUrl = client.storage.from('avatars').getPublicUrl(fileName);

      // อัพเดท URL ในตาราง users
      await client.from('users').update({
        'profile_image_url': imageUrl,
      }).eq('id', userId);

      return imageUrl;
    } catch (e) {
      print('Error updating profile image: $e');
      return null;
    }
  }

  // เพิ่ม method สำหรับลบรูปโปรไฟล์เก่า
  Future<void> deleteProfileImage(String userId) async {
    try {
      await client.storage.from('avatars').remove(['$userId/profile.*']);
    } catch (e) {
      print('Error deleting old profile image: $e');
    }
  }

  // เพิ่ม method สำหรับดึงข้อมูล posts
  // ลบฟังก์ชัน getPostsStream ตัวแรกออก เพราะซ้ำซ้อนกัน

  // เพิ่มโพสต์ใหม่
  Future<void> createPost({
    required String content,
    List<String>? imageUrls, // เปลี่ยนจาก String? เป็น List<String>?
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw 'Not logged in';

    await client.from('posts').insert({
      'user_id': user.id,
      'content': content,
      'image_urls': imageUrls, // เปลี่ยนชื่อ column ในฐานข้อมูลด้วย
    });
  }

  // แก้ไขฟังก์ชัน getPostsStream ใหม่
  Stream<List<Map<String, dynamic>>> getPostsStream() {
    return client
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((posts) async {
          final postsWithData = await Future.wait(
            posts.map((post) async {
              // ดึงข้อมูล user
              final userData = await client
                  .from('users')
                  .select()
                  .eq('id', post['user_id'])
                  .single();

              // ดึงจำนวน likes
              final likes = await client
                  .from('likes')
                  .select('id')
                  .eq('post_id', post['id']);

              // เช็คว่า current user ไลค์โพสต์นี้หรือยัง
              final user = client.auth.currentUser;
              bool isLiked = false;
              if (user != null) {
                final userLike = await client
                    .from('likes')
                    .select()
                    .eq('post_id', post['id'])
                    .eq('user_id', user.id)
                    .maybeSingle();
                isLiked = userLike != null;
              }

              return {
                ...post,
                'user': userData,
                'likes_count': likes.length,
                'is_liked': isLiked,
              };
            }),
          );
          return postsWithData;
        });
  }

  // เพิ่มฟังก์ชันสำหรับจัดการ likes
  Future<void> toggleLike(String postId) async {
    final user = client.auth.currentUser;
    if (user == null) throw 'Not logged in';

    // เช็คว่าเคยไลค์หรือยัง
    final likes = await client
        .from('likes')
        .select()
        .eq('post_id', postId)
        .eq('user_id', user.id);

    if (likes.isEmpty) {
      // ถ้ายังไม่เคยไลค์ ให้เพิ่ม like
      await client.from('likes').insert({
        'post_id': postId,
        'user_id': user.id,
      });
    } else {
      // ถ้าเคยไลค์แล้ว ให้ลบ like
      await client
          .from('likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', user.id);
    }
  }

  // เพิ่มคอมเมนต์
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw 'Not logged in';

    await client.from('comments').insert({
      'post_id': postId,
      'user_id': user.id,
      'content': content,
    });
  }

  // ดึงคอมเมนต์ของโพสต์แบบ realtime
  Stream<List<Map<String, dynamic>>> getCommentsStream(String postId) {
    return client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at')
        .asyncMap((comments) async {
          // ดึงข้อมูล user สำหรับแต่ละ comment
          final commentsWithUser = await Future.wait(
            comments.map((comment) async {
              final userData = await client
                  .from('users')
                  .select()
                  .eq('id', comment['user_id'])
                  .single();

              return {
                ...comment,
                'user': userData,
              };
            }),
          );
          return commentsWithUser;
        });
  }

  // เพิ่มฟังก์ชันลบ comment
  Future<void> deleteComment(String commentId) async {
    final user = client.auth.currentUser;
    if (user == null) throw 'Not logged in';

    try {
      print('Deleting comment: $commentId'); // Debug log

      final result = await client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', user.id);

      print('Delete result: $result'); // Debug log
    } catch (e) {
      print('Error deleting comment: $e'); // Debug log
      throw 'Failed to delete comment: $e';
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://tomatocarepj.netlify.app/auth/reset-password',
      );
    } catch (e) {
      print('Error sending password reset email: $e');
      throw 'Failed to send password reset email: $e';
    }
  }

  Future<Map<String, dynamic>> getDiseaseInfo(String diseaseName) async {
    try {
      final response = await client
          .from('diseases')
          .select()
          .eq('name', diseaseName)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('Disease not found in database: $diseaseName'); // Debug log
        // ส่งค่าเริ่มต้นถ้าไม่พบข้อมูล
        return {
          'name': diseaseName,
          'description': 'Disease information not available.',
          'symptoms': 'No symptoms information available.',
          'treatment': 'No treatment information available.',
          'prevention': 'No prevention information available.',
        };
      }

      return response;
    } catch (e) {
      print('Error getting disease info: $e');
      // ส่งค่าเริ่มต้นเมื่อเกิดข้อผิดพลาด
      return {
        'name': diseaseName,
        'description': 'Error loading disease information.',
        'symptoms': 'Error loading symptoms.',
        'treatment': 'Error loading treatment.',
        'prevention': 'Error loading prevention.',
      };
    }
  }

  // No need for explicit close with Supabase
  void close() {
    // Cleanup if needed
  }
}
