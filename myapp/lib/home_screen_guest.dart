// home_screen_guest.dart
import 'package:flutter/material.dart';
import 'navigation/guest_navigation.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  GuestHomePageState createState() => GuestHomePageState();
}

class GuestHomePageState extends State<GuestHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Gallery Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Camera Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Setting Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3), // พื้นหลังสีครีม
      body: _pages[_selectedIndex],
      bottomNavigationBar: GuestNavigation(
        // ใช้ GuestNavigation ที่นี่
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
