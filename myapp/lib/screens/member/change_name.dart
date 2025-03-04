import 'package:flutter/material.dart';

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({super.key});

  @override
  State<ChangeNameScreen> createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Name changed to $newName")),
      );
      Navigator.pop(context); // ✅ กลับไปหน้า Settings
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7D2424), // ✅ สีพื้นหลัง
        title: const Text(
          "Change Name",
          style: TextStyle(
            fontFamily: 'Questrial', // ✅ ฟอนต์
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ สีตัวอักษร
          ),
        ),
        centerTitle: true, // ✅ จัด title ให้อยู่ตรงกลาง
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // ✅ ปุ่มย้อนกลับ
          },
        ),
      ),
      backgroundColor: const Color(0xFFFDF6E3),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Enter New Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveName,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D2424),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
