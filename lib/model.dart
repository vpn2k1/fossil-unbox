import 'dart:math' as math;
import 'dart:ui';

typedef Json = Map<String, dynamic>;
double number(dynamic value) => (value as num).toDouble();
double radians(num degrees) => degrees * math.pi / 180;

class Bone {
  Bone(Json j)
      : id = j['id'],
        label = j['label'],
        asset = j['asset'],
        target = Offset(number(j['targetX']), number(j['targetY'])),
        size = Size(number(j['width']), number(j['height'])),
        angle = radians(j['targetAngle']),
        z = j['zIndex'];
  final String id, label, asset;
  final Offset target;
  final Size size;
  final double angle;
  final int z;
}

class Level {
  Level(Json j)
      : name = j['name'],
        id = j['id'],
        species = j['speciesId'],
        size = Size(number(j['board']['width']), number(j['board']['height'])),
        silhouette = j['board']['showSilhouette'],
        rotation = j['settings']['rotationEnabled'],
        radius = number(j['settings']['snapRadius']),
        tolerance = radians(j['settings']['angleToleranceDegrees']),
        free = j['settings']['freeHints'],
        reward = j['reward']['coins'],
        bones = [for (final b in j['bones']) Bone(b)] {
    bones.sort((a, b) => a.z.compareTo(b.z));
    for (final c in j['crates']) {
      for (final String bone in c['boneIds']) {
        if (crate.containsKey(bone)) throw FormatException('Mảnh trùng thùng');
        crate[bone] = c['id'];
      }
    }
    final ids = bones.map((b) => b.id).toSet();
    if (ids.isEmpty ||
        ids.length != bones.length ||
        ids.length != crate.length ||
        !ids.containsAll(crate.keys) ||
        size.isEmpty ||
        radius <= 0 ||
        bones.any((b) =>
            b.size.isEmpty || !(Offset.zero & size).contains(b.target))) {
      throw FormatException('Dữ liệu màn không hợp lệ');
    }
  }
  final int id, free, reward;
  final String name, species;
  final Size size;
  final bool rotation, silhouette;
  final double radius, tolerance;
  final List<Bone> bones;
  final crate = <String, String>{};
  bool accepts(Bone b, Offset point, double angle) =>
      (point - b.target).distance <= radius &&
      (!rotation ||
          math
                  .atan2(math.sin(angle - b.angle), math.cos(angle - b.angle))
                  .abs() <=
              tolerance);
}

class Progress {
  Progress();
  Set<String> opened = {}, placed = {};
  Map<String, double> angles = {};
  int used = 0, best = 0, coins = 0;
  bool sound = true, vibration = true, tutorialSeen = false;
  int get stars => used == 0
      ? 3
      : used <= 2
          ? 2
          : 1;
  void replay() {
    opened.clear();
    placed.clear();
    angles.clear();
    used = 0;
  }

  void finish(Level l) {
    if (placed.length != l.bones.length) return;
    if (best == 0) coins += l.reward;
    best = math.max(best, stars);
  }

  Json encode() => {
        'version': 1,
        'opened': opened.toList(),
        'placed': placed.toList(),
        'angles': angles,
        'used': used,
        'best': best,
        'coins': coins,
        'sound': sound,
        'vibration': vibration,
        'tutorialSeen': tutorialSeen
      };
  factory Progress.read(Json j, Level l) {
    if (j['version'] != 1) throw FormatException('Phiên bản lưu chưa hỗ trợ');
    final p = Progress();
    p.opened = Set<String>.from(j['opened']);
    p.placed = Set<String>.from(j['placed']);
    p.angles = (j['angles'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, number(v)));
    p.used = j['used'];
    p.best = j['best'];
    p.coins = j['coins'];
    p.sound = j['sound'];
    p.vibration = j['vibration'];
    p.tutorialSeen = j['tutorialSeen'] ?? (p.opened.isNotEmpty || p.best > 0);
    if (!l.crate.values.toSet().containsAll(p.opened) ||
        !l.crate.keys.toSet().containsAll(p.angles.keys) ||
        p.placed.any((k) => !p.opened.contains(l.crate[k])) ||
        p.used < 0 ||
        p.used > l.free ||
        p.best < 0 ||
        p.best > 3 ||
        p.coins < 0) {
      throw FormatException('Tiến trình không hợp lệ');
    }
    return p;
  }
}
