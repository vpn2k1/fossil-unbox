import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fossil_unbox/model.dart';

void main() {
  Json data() =>
      jsonDecode(File('assets/levels/level_001.json').readAsStringSync());
  final l = Level(data());
  test('Ngưỡng khoảng cách và xoay qua 0 độ', () {
    final b = l.bones.first;
    expect(l.accepts(b, b.target + Offset(l.radius, 0), 3), isTrue);
    expect(l.accepts(b, b.target + Offset(l.radius + .01, 0), 0), isFalse);
    final j = data();
    j['settings']['rotationEnabled'] = true;
    j['bones'][0]['targetAngle'] = 359;
    final rotated = Level(j), bone = rotated.bones.first;
    expect(rotated.accepts(bone, bone.target, radians(1)), isTrue);
    expect(rotated.accepts(bone, bone.target, radians(45)), isFalse);
  });
  test('Lưu, tiếp tục, cải thiện sao và giữ nguyên ví', () {
    final p = Progress()
      ..opened.addAll(l.crate.values)
      ..used = 3;
    p.placed.add(l.bones.first.id);
    final q = Progress.read(jsonDecode(jsonEncode(p.encode())), l);
    expect(q.placed, p.placed);
    q.placed.addAll(l.crate.keys);
    q.finish(l);
    q.finish(l);
    expect(q.best, 1);
    expect(q.coins, l.reward);
    q.replay();
    expect(q.placed, isEmpty);
    expect(q.best, 1);
    q.opened.addAll(l.crate.values);
    q.placed.addAll(l.crate.keys);
    q.finish(l);
    expect(q.best, 3);
    expect(q.coins, l.reward);
  });
  test('Từ chối mảnh chưa mở thùng và save phiên bản lạ', () {
    final j = Progress().encode();
    j['placed'] = [l.bones.first.id];
    expect(() => Progress.read(j, l), throwsFormatException);
    j['version'] = 9;
    expect(() => Progress.read(j, l), throwsFormatException);
  });
}
