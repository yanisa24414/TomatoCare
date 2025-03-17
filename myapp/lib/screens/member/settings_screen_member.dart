import 'package:flutter/material.dart';
import '../../navigation/tab_navigation.dart';
import '../../widgets/app_bar.dart';

class SettingsScreenMember extends StatelessWidget {
  const SettingsScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {},
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
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
        isMember: true,
        selectedIndex: 4,
        onTabPress: (index) => Navigator.pushReplacementNamed(
          context,
          [
            '/member/home',
            '/member/gallery',
            '/member/camera',
            '/member/post',
            '/member/settings'
          ][index],
        ),
      ),
    );
  }
}
