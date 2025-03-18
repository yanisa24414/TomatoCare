import 'package:flutter/material.dart';
import '../member/home_screen_member.dart';
import '../member/gallery_screen_member.dart';
import '../member/camera_screen_member.dart';
import '../member/post_screen_member.dart';
import '../member/settings_screen_member.dart';
import '../guest/home_screen_guest.dart';
import '../guest/gallery_screen_guest.dart';
import '../guest/camera_screen_guest.dart';
import '../guest/settings_screen_guest.dart';
import '../../navigation/tab_navigation.dart';

class BaseScreen extends StatefulWidget {
  final bool isMember;

  const BaseScreen({super.key, required this.isMember});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _memberScreens;
  late final List<Widget> _guestScreens;

  @override
  void initState() {
    super.initState();
    _memberScreens = [
      const HomeScreenMember(),
      const GalleryScreenMember(),
      const CameraScreenMember(),
      const PostScreenMember(),
      const SettingsScreenMember(),
    ];

    _guestScreens = [
      const HomeScreenGuest(),
      const GalleryScreenGuest(),
      const CameraScreenGuest(),
      const SettingsScreenGuest(),
    ];
  }

  void _onTabPress(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.isMember ? _memberScreens : _guestScreens,
      ),
      bottomNavigationBar: TabNavigation(
        isMember: widget.isMember,
        selectedIndex: _selectedIndex,
        onTabPress: _onTabPress,
      ),
    );
  }
}
