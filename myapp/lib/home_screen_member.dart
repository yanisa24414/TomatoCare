import 'package:flutter/material.dart';
import 'navigation/member_navigation.dart'; // นำเข้า MemberNavigation

class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key});

  @override
  MemberHomePageState createState() => MemberHomePageState();
}

class MemberHomePageState extends State<MemberHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Gallery Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Camera Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Post Page', style: TextStyle(fontSize: 24))),
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
      bottomNavigationBar: MemberNavigation(
        // ใช้ MemberNavigation ที่นี่
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
