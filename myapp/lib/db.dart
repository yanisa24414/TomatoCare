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

      // อัพโหลดไฟล์ไปที่ storage
      await client.storage.from('avatars').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

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

  // No need for explicit close with Supabase
  void close() {
    // Cleanup if needed
  }
}
