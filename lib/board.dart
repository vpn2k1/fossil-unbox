import 'dart:ui';
import 'package:flame/game.dart';
import 'model.dart';

class FossilBoard extends FlameGame {
  FossilBoard(this.level, this.progress, this.sprites);
  final Level level;
  Progress progress;
  final Map<String, Image> sprites;
  String? hint;
  double glow = 0;
  @override
  Color backgroundColor() => const Color(0xfff4e9d2);
  @override
  void update(double dt) {
    super.update(dt);
    if (glow > 0) glow -= dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.scale(size.x / level.size.width, size.y / level.size.height);
    final grid = Paint()
      ..color = const Color(0xffe4d7bd)
      ..strokeWidth = .65;
    for (double x = 0; x < level.size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, level.size.height), grid);
    }
    for (double y = 0; y < level.size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(level.size.width, y), grid);
    }
    for (final b in level.bones) {
      final locked = progress.placed.contains(b.id);
      final lit = glow > 0 && hint == b.id;
      if (!locked && !level.silhouette && !lit) continue;
      final image = sprites[b.asset]!;
      final ink = Paint()..filterQuality = FilterQuality.medium;
      if (!locked) {
        ink.colorFilter = ColorFilter.mode(
            Color(lit ? 0xffce8229 : 0xffd0bea2), BlendMode.srcIn);
      }
      canvas.save();
      canvas.translate(b.target.dx, b.target.dy);
      canvas.rotate(b.angle);
      canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromCenter(
              center: Offset.zero, width: b.size.width, height: b.size.height),
          ink);
      canvas.restore();
    }
    canvas.restore();
  }
}
