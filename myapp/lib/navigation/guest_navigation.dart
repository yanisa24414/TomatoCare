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
        route = '/common/gallery';
        break;
      case 2:
        route = '/common/camera';
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
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF7D2424), // สีพื้นหลังเรียบ
      elevation: 0, // เอาเงาออก
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white, // สีไอคอนเมื่อถูกเลือก
      unselectedItemColor: Colors.white70, // สีไอคอนที่ไม่ได้เลือก
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
