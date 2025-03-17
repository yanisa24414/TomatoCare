import 'package:flutter/material.dart';
import 'package:myapp/navigation/tab_navigation.dart';
import 'package:myapp/widgets/app_bar.dart';

class SettingsScreenGuest extends StatelessWidget {
  const SettingsScreenGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7D2424),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Questrial',
              color: Colors.white,
            ),
          ),
        ),
      ),
      bottomNavigationBar: TabNavigation(
        isMember: false,
        selectedIndex: 3,
        onTabPress: (index) {
          final routes = [
            '/guest/home',
            '/common/gallery',
            '/common/camera',
            '/guest/settings'
          ];
          Navigator.pushReplacementNamed(
            context,
            routes[index],
            arguments: index == 1 || index == 2 ? {'isMember': false} : null,
          );
        },
      ),
    );
  }
}
