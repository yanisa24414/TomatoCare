import 'package:flutter/material.dart';
import '../../widgets/app_bar.dart';
import '../auth/login_screen.dart';

class SettingsScreenMember extends StatelessWidget {
  const SettingsScreenMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Settings"),
      backgroundColor: const Color(0xFFFDF6E3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // My Account Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22512F),
                        fontFamily: 'Questrial', // เปลี่ยนเป็น Questrial
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading:
                          const Icon(Icons.person, color: Color(0xFF22512F)),
                      title: const Text('Edit Profile',
                          style: TextStyle(
                              fontFamily:
                                  'Questrial')), // เปลี่ยนเป็น Questrial
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // History Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22512F),
                        fontFamily: 'Questrial', // เปลี่ยนเป็น Questrial
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      leading:
                          const Icon(Icons.history, color: Color(0xFF22512F)),
                      title: const Text('View History',
                          style: TextStyle(
                              fontFamily:
                                  'Questrial')), // เปลี่ยนเป็น Questrial
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7D2424),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Questrial', // เปลี่ยนเป็น Questrial
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
