import 'package:flutter/material.dart';
import '../../../navigation/guest_navigation.dart';
import '../../../widgets/app_bar.dart'; // ✅ Import CustomAppBar
import 'package:myapp/widgets/post_card.dart';

class HomeScreenGuest extends StatelessWidget {
  const HomeScreenGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: const CustomAppBar(title: "TOMATO CARE"),
      body: Column(
        children: [
          // ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
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

          // รายการโพสต์ (สไลด์ได้)
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
      bottomNavigationBar: const GuestNavigation(selectedIndex: 0),
    );
  }
}
