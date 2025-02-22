import 'package:flutter/material.dart';
import '../../../navigation/guest_navigation.dart';

class CameraScreenGuest extends StatelessWidget {
  const CameraScreenGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: const Center(
        child: Text('Camera guest ', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const GuestNavigation(selectedIndex: 2),
    );
  }
}
