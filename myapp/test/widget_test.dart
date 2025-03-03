import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart'; // นำเข้า main.dart

void main() {
  testWidgets('แอปโหลดและแสดงผลได้ถูกต้อง', (WidgetTester tester) async {
    // สร้างแอปและเรนเดอร์บนหน้าจอทดสอบ
    await tester.pumpWidget(const MyApp());

    // ตรวจสอบว่ามีองค์ประกอบที่สำคัญแสดงอยู่ (แก้ไขให้ตรงกับ UI ของเธอ)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
