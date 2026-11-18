import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossil_unbox/main.dart';
import 'package:fossil_unbox/workshop_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Từ trang chủ đến bàn ghép và đặt mảnh bằng hai lần chạm',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
        theme: workshopTheme(Brightness.light), home: const Workshop()));
    for (var frame = 0;
        frame < 100 && find.text('Chơi').evaluate().isEmpty;
        frame++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 16));
    }
    Future<void> tap(String text) async {
      final f = find.text(text);
      await tester.ensureVisible(f);
      await tester.tap(f);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    }

    await tap('Chơi');
    await tap('Bỏ qua hướng dẫn');
    await tap('0/4 mảnh đã ghép');
    await tap('Mở thùng A · 2 mảnh');
    await tap('Đến bàn ghép');
    expect(find.text('Đã ghép 0/4 mảnh'), findsOneWidget);
    await tap('Đuôi');
    final area = tester.getRect(find.byWidgetPredicate((w) => w is GameWidget));
    await tester.tapAt(
        area.topLeft + Offset(area.width * 78 / 400, area.height * 111 / 280));
    await tester.pump();
    expect(find.text('Đã ghép 1/4 mảnh'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
