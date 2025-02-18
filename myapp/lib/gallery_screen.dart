import 'package:flutter/material.dart';
import '../navigation/guest_navigation.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: const Center(
        child: Text('Gallery Page', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const GuestNavigation(selectedIndex: 1),
    );
  }
}
