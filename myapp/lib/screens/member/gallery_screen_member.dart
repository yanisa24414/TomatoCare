import 'package:flutter/material.dart';
import '../../../navigation/member_navigation.dart';

class GalleryScreenMember extends StatelessWidget {
  const GalleryScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: const Center(
        child: Text('Gallery member', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const MemberNavigation(selectedIndex: 1),
    );
  }
}
