import 'package:flutter/material.dart';
import '../navigation/guest_navigation.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 170, 130, 21),
      body: const Center(
        child: Text('Camera Page', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const GuestNavigation(selectedIndex: 2),
    );
  }
}
