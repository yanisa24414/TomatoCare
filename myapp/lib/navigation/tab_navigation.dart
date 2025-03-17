import 'package:flutter/material.dart';

class TabNavigation extends StatelessWidget {
  final bool isMember;
  final int selectedIndex;
  final Function(int) onTabPress;

  const TabNavigation({
    super.key,
    required this.isMember,
    required this.selectedIndex,
    required this.onTabPress,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        if (index == selectedIndex) return;

        // แทนการใช้ pushReplacementNamed ด้วย pushNamed เพื่อรักษา state ของ tab
        Navigator.pushNamed(
          context,
          _getRoute(index),
          arguments: index == 1 || index == 2 ? {'isMember': isMember} : null,
        );
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFDF6E3),
      selectedItemColor:
          isMember ? const Color(0xFF22512F) : const Color(0xFF7D2424),
      items: isMember
          ? const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ]
          : const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
    );
  }

  String _getRoute(int index) {
    if (isMember) {
      switch (index) {
        case 0:
          return '/member/home';
        case 1:
          return '/member/gallery'; // แก้จาก '/common/gallery'
        case 2:
          return '/member/camera'; // แก้จาก '/common/camera'
        case 3:
          return '/member/post';
        case 4:
          return '/member/settings';
        default:
          return '/member/home';
      }
    } else {
      switch (index) {
        case 0:
          return '/guest/home';
        case 1:
          return '/guest/gallery';
        case 2:
          return '/guest/camera';
        case 3:
          return '/guest/settings';
        default:
          return '/guest/home';
      }
    }
  }
}
