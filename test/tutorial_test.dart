import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossil_unbox/model.dart';
import 'package:fossil_unbox/tutorial.dart';

void main() {
  final bone = Bone({
    'id': 'tail',
    'label': 'Đuôi',
    'asset': 'tail.png',
    'targetX': 10,
    'targetY': 10,
    'width': 112,
    'height': 64,
    'targetAngle': 0,
    'zIndex': 1,
  });
  testWidgets('Mở thùng, kéo thử, vào bản đồ', (tester) async {
    var exited = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Tutorial(
            bone: bone,
            onContinue: () {
              exited = true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mở thùng tập'));
    await tester.pump();
    final source = tester.getCenter(find.byType(Draggable<String>));
    final target = tester.getCenter(find.byType(DragTarget<String>));
    await tester.dragFrom(source, target - source);
    await tester.pump();
    expect(find.text('Vào bản đồ'), findsOneWidget);
    await tester.tap(find.text('Vào bản đồ'));
    expect(exited, isTrue);
  });
  testWidgets('Chạm chọn ở bố cục hẹp với chữ lớn', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
            child: SingleChildScrollView(
              child: Tutorial(bone: bone, onContinue: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mở thùng tập'));
    await tester.pump();
    await tester.tap(find.byType(Draggable<String>));
    await tester.pump();
    expect(find.text('Chạm bóng xương phía trên để ghép.'), findsOneWidget);
    await tester.tap(find.byType(DragTarget<String>));
    await tester.pump();
    expect(find.text('Vào bản đồ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Bỏ qua trước khi mở thùng', (tester) async {
    var exited = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Tutorial(
            bone: bone,
            onContinue: () {
              exited = true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Bỏ qua hướng dẫn'));
    expect(exited, isTrue);
  });
}
