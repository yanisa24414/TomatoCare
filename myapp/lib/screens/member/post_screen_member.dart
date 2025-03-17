import 'package:flutter/material.dart';
import '../../navigation/tab_navigation.dart';
import '../../widgets/app_bar.dart';

class PostScreenMember extends StatelessWidget {
  const PostScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Create Post"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: const Center(
        child: Text('Post Screen Content'),
      ),
      bottomNavigationBar: TabNavigation(
        isMember: true,
        selectedIndex: 3,
        onTabPress: (index) => Navigator.pushReplacementNamed(
          context,
          [
            '/member/home',
            '/member/gallery',
            '/member/camera',
            '/member/post',
            '/member/settings'
          ][index],
        ),
      ),
    );
  }
}
