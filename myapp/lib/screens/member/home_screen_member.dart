import 'package:flutter/material.dart';
import '../../navigation/tab_navigation.dart';
import '../../../widgets/app_bar.dart'; // ✅ Import CustomAppBar
import 'package:myapp/widgets/post_card.dart';

class HomeScreenMember extends StatelessWidget {
  const HomeScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),

      // ✅ ใช้ CustomAppBar (ฟอนต์ Questrial)
      appBar: const CustomAppBar(title: "TOMATO CARE"),

      body: Column(
        children: [
          // ✅ ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle:
                    const TextStyle(fontFamily: 'Questrial'), // ✅ ใช้ Questrial
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ✅ รายการโพสต์ (สไลด์ได้)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: const [
                PostCard(
                  username: "SomSri K.",
                  postText: "โรคนี้เกิดขึ้นบ่อยไหมคะ",
                  imagePath: "assets/leaf1.jpg",
                ),
                PostCard(
                  username: "Poom V.",
                  postText: "มีใครมีแหล่งขายปุ๋ยและยารักษาโรคที่ครบวงจรไหมครับ",
                  imagePath: null,
                ),
                PostCard(
                  username: "Nui T.",
                  postText: "อยากรู้ว่ามีวิธีป้องกันโรคพวกนี้ไหม",
                  imagePath: null,
                ),
                PostCard(
                  username: "Arthit B.",
                  postText:
                      "ต้นมะเขือเทศที่บ้านเริ่มเป็นแบบนี้ มีวิธีแก้ไขไหม?",
                  imagePath: "assets/leaf2.jpg",
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: TabNavigation(
        isMember: true,
        selectedIndex: 0,
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
