import 'package:flutter/material.dart';

class GuestNavigation extends StatelessWidget {
  final int selectedIndex;

  const GuestNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _navigateToScreen(BuildContext context, int index) {
    String route = '/home'; // ค่าเริ่มต้น
    switch (index) {
      case 0:
        route = '/home';
        break;
      case 1:
        route = '/gallery';
        break;
      case 2:
        route = '/camera';
        break;
      case 3:
        route = '/settings';
        break;
    }

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF7D2424),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      currentIndex: selectedIndex,
      onTap: (index) => _navigateToScreen(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Gallery'),
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
    );
  }
}
