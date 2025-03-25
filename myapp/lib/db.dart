import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // เพิ่มบรรทัดนี้
import 'package:logging/logging.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  late final SupabaseClient client;
  DateTime? _lastRegistrationAttempt;
  static final _log = Logger('DatabaseHelper');

  // Private constructor
  DatabaseHelper._internal() {
    client = Supabase.instance.client;
  }

  Future<bool> testConnection() async {
    try {
      await client.from('users').select().limit(1);
      _log.info('Database connection successful');
      return true;
    } catch (e) {
      _log.severe('Database connection failed: $e');
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
      _log.info("Starting registration for email: $email");

      // สร้าง auth user โดยไม่ต้องรอการยืนยัน email
      final AuthResponse auth = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'email_confirm': true, // เพิ่มบรรทัดนี้เพื่อข้ามการยืนยัน email
        },
        emailRedirectTo: null,
      );

      if (auth.user == null) throw 'Registration failed: No user data received';

      _log.info("Auth user created with ID: ${auth.user!.id}");

      // บันทึกข้อมูลใน users table
      await client.from('users').insert({
        'id': auth.user!.id,
        'email': email,
        'username': username,
      });

      // ทำการ login อัตโนมัติ
      if (auth.session != null) {
        await client.auth.setSession(auth.session!.refreshToken!);
      }

      _log.info("User registered and logged in successfully");
    } catch (e, stackTrace) {
      _log.severe("Detailed error: $e");
      _log.severe("Stack trace: $stackTrace");

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
      _log.info("Attempting login for email: $email");

      // Try to sign in with Supabase Auth
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Check if we got a valid user and session
      if (response.user != null && response.session != null) {
        _log.info("Auth successful, getting user data");

        // Get user data from our users table
        final userData = await client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();

        _log.info("User data retrieved: $userData");

        // Store session
        await client.auth.setSession(response.session!.refreshToken!);

        return response.user;
      }

      _log.severe("Login failed - no user data or session");
      return null;
    } catch (e) {
      _log.severe("Login error: $e");
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
      _log.info('Starting profile image update for user: $userId');

      // 1. สร้างชื่อไฟล์จาก userId
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/profile.$fileExt';
      final fileBytes = await imageFile.readAsBytes();

      _log.info('Uploading image to storage: $fileName');

      // 2. อัพโหลดไฟล์ไปที่ avatars bucket
      await client.storage.from('avatars').uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // ทับไฟล์เดิมถ้ามีอยู่แล้ว
            ),
          );

      // 3. สร้าง public URL
      final imageUrl = client.storage.from('avatars').getPublicUrl(fileName);
      _log.info('Generated public URL: $imageUrl');

      // 4. อัพเดท profile_image_url ในตาราง users
      await client.from('users').update({
        'profile_image_url': imageUrl,
      }).eq('id', userId);

      _log.info('Profile image updated successfully');
      return imageUrl;
    } catch (e) {
      _log.severe('Error updating profile image: $e');
      return null;
    }
  }

  // เพิ่ม method สำหรับลบรูปโปรไฟล์เก่า
  Future<void> deleteProfileImage(String userId) async {
    try {
      await client.storage.from('avatars').remove(['$userId/profile.*']);
    } catch (e) {
      _log.severe('Error deleting old profile image: $e');
    }
  }

  // เพิ่ม method สำหรับดึงข้อมูล posts
  // ลบฟังก์ชัน getPostsStream ตัวแรกออก เพราะซ้ำซ้อนกัน

  // เพิ่มโพสต์ใหม่
  Future<void> createPost({
    required String content,
    List<File>? images,
  }) async {
    try {
      final user = client.auth.currentUser;
      if (user == null) throw 'Not logged in';

      List<String> imageUrls = [];

      // 1. อัพโหลดรูปภาพ (ถ้ามี)
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          final fileExt = image.path.split('.').last;
          final fileName =
              'post_${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.$fileExt';

          // อัพโหลดไฟล์
          await client.storage.from('post-images').uploadBinary(
                fileName,
                await image.readAsBytes(),
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: true,
                ),
              );

          // สร้าง public URL
          final imageUrl =
              client.storage.from('post-images').getPublicUrl(fileName);
          imageUrls.add(imageUrl);
        }
      }

      // 2. สร้างโพสต์พร้อมรูปภาพ
      await client.from('posts').insert({
        'user_id': user.id,
        'content': content,
        'image_urls': imageUrls,
        'created_at': DateTime.now().toIso8601String(),
      });

      _log.info('Post created successfully with ${imageUrls.length} images');
    } catch (e) {
      _log.severe('Error creating post: $e');
      throw 'Failed to create post: $e';
    }
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
      _log.fine('Deleting comment: $commentId'); // Debug log

      final result = await client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', user.id);

      _log.fine('Delete result: $result'); // Debug log
    } catch (e) {
      _log.severe('Error deleting comment: $e'); // Debug log
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
      _log.severe('Error sending password reset email: $e');
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
        _log.fine('Disease not found in database: $diseaseName'); // Debug log
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
      _log.severe('Error getting disease info: $e');
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

  Stream<List<Map<String, dynamic>>> getUserScans() {
    final user = client.auth.currentUser;
    if (user == null) return Stream.value([]);

    try {
      return client
          .from('scan_history') // เปลี่ยนจาก analysis_history เป็น scan_history
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .map((data) {
            _log.fine('Scan data received: $data'); // Debug log
            return List<Map<String, dynamic>>.from(data);
          });
    } catch (e) {
      _log.severe('Error getting user scans: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> getUserPosts() {
    final user = client.auth.currentUser;
    if (user == null) return Stream.value([]);

    return client
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
  }

  Future<void> recordActivity({
    required String activityType,
    required String description,
    String? referenceId,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      await client.from('user_activities').insert({
        'user_id': user.id,
        'activity_type': activityType,
        'description': description,
        'reference_id': referenceId,
      });
    } catch (e) {
      _log.severe('Error recording activity: $e');
    }
  }

  // ปรับปรุง getUserActivities ให้แสดงข้อมูลละเอียดขึ้น
  Stream<List<Map<String, dynamic>>> getUserActivities() {
    final user = client.auth.currentUser;
    if (user == null) return Stream.value([]);

    try {
      return Stream.periodic(const Duration(seconds: 3)).asyncMap((_) async {
        List<Map<String, dynamic>> activities = [];

        // ดึงข้อมูล likes พร้อมข้อมูลโพสต์
        final likes = await client.from('likes').select('''
              id,
              created_at,
              posts (
                content
              )
            ''').eq('user_id', user.id).order('created_at', ascending: false);

        // ดึงข้อมูล comments พร้อมข้อมูลโพสต์
        final comments = await client.from('comments').select('''
              id,
              content,
              created_at,
              posts (
                content
              )
            ''').eq('user_id', user.id).order('created_at', ascending: false);

        // แปลง likes เป็นกิจกรรม
        activities.addAll(likes.map((like) => {
              'id': like['id'],
              'type': 'like',
              'created_at': like['created_at'],
              'description':
                  'Liked post: "${like['posts']?['content'] ?? 'Unknown post'}"',
            }));

        // แปลง comments เป็นกิจกรรม
        activities.addAll(comments.map((comment) => {
              'id': comment['id'],
              'type': 'comment',
              'created_at': comment['created_at'],
              'description': 'Commented: "${comment['content']}"',
            }));

        // เรียงตามเวลา
        activities.sort((a, b) => DateTime.parse(b['created_at'])
            .compareTo(DateTime.parse(a['created_at'])));

        return activities;
      });
    } catch (e) {
      _log.severe('Error getting user activities: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> searchPosts(String searchTerm) {
    return Stream.fromFuture(client
            .from('posts')
            .select()
            .ilike('content', '%$searchTerm%')
            .order('created_at', ascending: false))
        .asyncMap((posts) async {
      final postsWithData = await Future.wait(
        posts.map((post) async {
          final userData = await client
              .from('users')
              .select()
              .eq('id', post['user_id'])
              .single();

          final likes =
              await client.from('likes').select('id').eq('post_id', post['id']);

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

  Future<void> deletePost(String postId) async {
    final user = client.auth.currentUser;
    if (user == null) throw 'Not logged in';

    try {
      // ตรวจสอบว่าเป็นเจ้าของโพสต์หรือไม่
      final post = await client
          .from('posts')
          .select()
          .eq('id', postId)
          .eq('user_id', user.id)
          .single();

      if (post == null) {
        throw 'Post not found or you do not have permission to delete it';
      }

      // ลบข้อมูลที่เกี่ยวข้องทั้งหมด
      await client.from('likes').delete().eq('post_id', postId);
      await client.from('comments').delete().eq('post_id', postId);
      await client.from('posts').delete().eq('id', postId);
    } catch (e) {
      _log.severe('Error deleting post: $e');
      throw 'Failed to delete post: $e';
    }
  }
}
