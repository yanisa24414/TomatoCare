import 'package:flutter/material.dart';
import '../../navigation/tab_navigation.dart';
import '../../widgets/app_bar.dart';

class SettingsScreenGuest extends StatelessWidget {
  const SettingsScreenGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Sign in'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
          ),
          const ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
          ),
        ],
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
