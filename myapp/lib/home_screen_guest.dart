import 'package:flutter/material.dart';
import 'navigation/guest_navigation.dart';
import 'setting_screen_guest.dart'; // นำเข้า SettingScreenGuest

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
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingScreenGuest()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      body: _selectedIndex < _pages.length
          ? _pages[_selectedIndex]
          : const Center(
              child: Text('Page not found', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: GuestNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
