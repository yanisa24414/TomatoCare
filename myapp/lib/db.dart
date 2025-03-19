import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Check rate limit
      if (_lastRegistrationAttempt != null) {
        final timeDiff = DateTime.now().difference(_lastRegistrationAttempt!);
        if (timeDiff.inSeconds < 30) {
          throw 'Please wait ${30 - timeDiff.inSeconds} seconds before trying again';
        }
      }

      _lastRegistrationAttempt = DateTime.now();
      print("Starting registration for email: $email");

      // Create auth user
      final AuthResponse auth = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (auth.user == null) {
        throw 'Registration failed: No user data received';
      }

      // Insert user data with null profile_image
      final response = await client
          .from('users')
          .insert({
            'email': email,
            'username': username,
            'profile_image': null, // เพิ่ม field นี้
          })
          .select()
          .single();

      print("User registered with ID: ${response['id']}");
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

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      print("Attempting login for email: $email");

      final AuthResponse res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        print("Login successful for user: ${res.user!.email}");
        return res.user;
      } else {
        print("Login failed: No user data received");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      throw 'Invalid email or password';
    }
  }

  // Query all users (for debugging)
  Future<List<Map<String, dynamic>>> queryUsers() async {
    final response = await client.from('users').select();
    return response;
  }

  // No need for explicit close with Supabase
  void close() {
    // Cleanup if needed
  }
}
