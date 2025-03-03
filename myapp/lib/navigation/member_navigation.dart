import 'package:flutter/material.dart';

class MemberNavigation extends StatelessWidget {
  final int selectedIndex;

  const MemberNavigation({super.key, required this.selectedIndex});

  void _navigateToScreen(BuildContext context, int index) {
    String route = '/member/home'; // ค่าเริ่มต้น
    Object? arguments;

    switch (index) {
      case 0:
        route = '/member/home';
        break;
      case 1:
        route = '/common/gallery';
        arguments = {'isMember': true}; // ✅ ส่งค่า isMember
        break;
      case 2:
        route = '/common/camera';
        arguments = {'isMember': true}; // ✅ ส่งค่า isMember
        break;
      case 3:
        route = '/member/post';
        break;
      case 4:
        route = '/member/settings';
        break;
    }

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route, arguments: arguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF7D2424), // ✅ ใช้สีแดงเข้ม ไม่มี Gradient
      elevation: 0, // ✅ ลบเงาออก
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: selectedIndex,
      onTap: (index) => _navigateToScreen(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Gallery'),
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
        BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
    );
  }
}
