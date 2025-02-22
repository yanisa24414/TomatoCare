import 'package:flutter/material.dart';

class GuestNavigation extends StatelessWidget {
  final int selectedIndex;

  const GuestNavigation({super.key, required this.selectedIndex});

  void _navigateToScreen(BuildContext context, int index) {
    String route = '/guest/home'; // ค่าเริ่มต้น
    switch (index) {
      case 0:
        route = '/guest/home';
        break;
      case 1:
        route = '/guest/gallery';
        break;
      case 2:
        route = '/guest/camera';
        break;
      case 3:
        route = '/guest/settings';
        break;
    }

    // เปลี่ยนหน้าเฉพาะเมื่อไม่ได้อยู่ในหน้านั้นอยู่แล้ว
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF7D2424),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: selectedIndex,
          onTap: (index) => _navigateToScreen(context, index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Gallery'),
            BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Setting'),
          ],
        ),
      ),
    );
  }
}
