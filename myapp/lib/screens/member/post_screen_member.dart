import 'package:flutter/material.dart';
import '../../navigation/member_navigation.dart';
import '../../../widgets/app_bar.dart'; // ✅ Import CustomAppBar

class PostScreenMember extends StatelessWidget {
  const PostScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Post Page"), // ✅ เพิ่ม AppBar
      backgroundColor: const Color(0xFFFDF6E3),
      body: const Center(
        child: Text('Post page', style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const MemberNavigation(
          selectedIndex:
              3), // ✅ ตั้งค่า selectedIndex เป็น 3 เพราะเป็นหน้าของโพสต์
    );
  }
}
