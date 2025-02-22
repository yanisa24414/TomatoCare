import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

// Mock AuthService แทนการเชื่อมต่อจริง
class FakeAuthService {
  static Future<bool> isMember() async =>
      Future.value(false); // หรือ true ถ้าต้องการทดสอบ Member
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // โหลดค่า isMember (mocked)
    bool isMember = await FakeAuthService.isMember();

    // สร้างแอปโดยใช้ค่า isMember ที่ mock ไว้
    await tester.pumpWidget(MyApp(isMember: isMember));

    // ตรวจสอบว่า Counter เริ่มต้นที่ 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // กดปุ่มเพิ่มค่า (+)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // ตรวจสอบว่า Counter เปลี่ยนเป็น 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
