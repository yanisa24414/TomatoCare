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
      onTap: onTabPress,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFDF6E3),
      selectedItemColor:
          isMember ? const Color(0xFF7D2424) : const Color(0xFF7D2424),
      selectedLabelStyle:
          const TextStyle(fontFamily: 'Questrial'), // เพิ่ม font
      unselectedLabelStyle:
          const TextStyle(fontFamily: 'Questrial'), // เพิ่ม font
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
}
