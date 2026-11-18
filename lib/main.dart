import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flame/game.dart' show GameWidget;
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'board.dart';
import 'model.dart';
import 'tutorial.dart';
import 'workshop_style.dart';

void main() => runApp(
      MaterialApp(
        title: 'Fossil Unbox',
        debugShowCheckedModeBanner: false,
        theme: workshopTheme(Brightness.light),
        darkTheme: workshopTheme(Brightness.dark),
        home: const Workshop(),
      ),
    );

enum PageId { home, tutorial, map, crates, play, victory, museum, settings }

class Workshop extends StatefulWidget {
  const Workshop({super.key});
  @override
  State<Workshop> createState() => _WorkshopState();
}

class _WorkshopState extends State<Workshop> {
  final boardKey = GlobalKey();
  final camera = TransformationController();
  late Level level;
  late Progress p;
  late SharedPreferences prefs;
  late FossilBoard board;
  final sprites = <String, ui.Image>{};
  PageId page = PageId.home;
  bool ready = false, writing = false, dragCancelled = false;
  String? loadError, selection;
  PageId tutorialOrigin = PageId.home;
  static const saveKey = 'fossil.level1.v1';
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      level = Level(
        jsonDecode(await rootBundle.loadString('assets/levels/level_001.json')),
      );
      for (final b in level.bones) {
        final bytes = await rootBundle.load('assets/images/${b.asset}');
        final codec = await ui.instantiateImageCodec(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
        sprites[b.asset] = (await codec.getNextFrame()).image;
        codec.dispose();
      }
      prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(saveKey);
      p = raw == null ? Progress() : Progress.read(jsonDecode(raw), level);
      board = FossilBoard(level, p, sprites);
      if (mounted)
        setState(() {
          ready = true;
          loadError = null;
        });
    } catch (e) {
      if (mounted)
        setState(
          () => loadError =
              'Không đọc được màn hoặc tiến trình. Dữ liệu đã lưu vẫn được giữ.',
        );
    }
  }

  void message(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(s)));
  }

  Future<bool> save(void Function(Progress) change) async {
    if (writing) return false;
    final next = Progress.read(jsonDecode(jsonEncode(p.encode())), level);
    change(next);
    setState(() => writing = true);
    try {
      if (!await prefs.setString(saveKey, jsonEncode(next.encode())))
        throw StateError('ghi');
      if (!mounted) return false;
      setState(() {
        p = next;
        board.progress = p;
      });
      return true;
    } catch (e) {
      if (mounted) message('Chưa lưu được. Hãy thử lại.');
      return false;
    } finally {
      if (mounted) setState(() => writing = false);
    }
  }

  void go(PageId next) {
    if (mounted) setState(() => page = next);
  }

  bool get complete => p.placed.length == level.bones.length;
  void resume() => go(
        complete
            ? PageId.victory
            : p.opened.isEmpty
                ? PageId.crates
                : PageId.play,
      );
  void openTutorial(PageId origin) {
    tutorialOrigin = origin;
    go(PageId.tutorial);
  }

  Future<void> leaveTutorial() async {
    if (p.tutorialSeen || await save((n) => n.tutorialSeen = true))
      go(tutorialOrigin == PageId.settings ? PageId.settings : PageId.map);
  }

  void back() => go(switch (page) {
        PageId.tutorial => tutorialOrigin,
        PageId.play || PageId.crates => PageId.map,
        _ => PageId.home,
      });
  List<Bone> get tray => level.bones
      .where(
        (b) => p.opened.contains(level.crate[b.id]) && !p.placed.contains(b.id),
      )
      .toList();
  void drop(Bone b, Offset screen) async {
    final box = boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || writing || !tray.contains(b)) return;
    final local = box.globalToLocal(screen);
    final world = Offset(
      local.dx / box.size.width * level.size.width,
      local.dy / box.size.height * level.size.height,
    );
    if (!level.accepts(b, world, p.angles[b.id] ?? 0)) {
      message('Chưa khớp. Mảnh đã về khay.');
      return;
    }
    if (!await save((n) {
          n.placed.add(b.id);
          n.finish(level);
        }) ||
        !mounted) return;
    setState(() => selection = null);
    if (p.vibration) HapticFeedback.selectionClick();
    if (p.sound) {
      try {
        await FlameAudio.play('snap.wav', volume: .55);
      } catch (_) {}
    }
    if (mounted && complete && page == PageId.play) go(PageId.victory);
  }

  Future<void> hint() async {
    if (tray.isEmpty || p.used >= level.free) return;
    final b = tray.firstWhere(
      (b) => b.id == selection,
      orElse: () => tray.first,
    );
    if (await save((n) => n.used++)) {
      board.hint = b.id;
      board.glow = 3;
      if (mounted) message('Vị trí ${b.label.toLowerCase()} đang sáng.');
    }
  }

  Widget button(
    String label,
    VoidCallback? tap, {
    IconData icon = Icons.arrow_forward,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: FilledButton.icon(
          onPressed: writing ? null : tap,
          icon: Icon(icon),
          label: Text(label),
        ),
      );
  Widget title(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          t,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontFamily: 'serif'),
        ),
      );
  Widget specimen() => AspectRatio(
        aspectRatio: level.size.aspectRatio,
        child: LayoutBuilder(
          builder: (_, c) => Stack(
            children: [
              for (final b in level.bones)
                Positioned(
                  left: (b.target.dx - b.size.width / 2) *
                      c.maxWidth /
                      level.size.width,
                  top: (b.target.dy - b.size.height / 2) *
                      c.maxHeight /
                      level.size.height,
                  width: b.size.width * c.maxWidth / level.size.width,
                  height: b.size.height * c.maxHeight / level.size.height,
                  child: Transform.rotate(
                    angle: b.angle,
                    child: Image.asset('assets/images/${b.asset}'),
                  ),
                ),
            ],
          ),
        ),
      );
  Widget mount() => SpecimenMount(specimen: specimen(), caption: level.name);
  Widget section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
  Widget navigation(String text, IconData icon, VoidCallback action) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Icon(icon),
        title: Text(text),
        trailing: const Icon(Icons.chevron_right),
        onTap: action,
      );
  List<Widget> contents() {
    switch (page) {
      case PageId.home:
        return [
          title('Xưởng hóa thạch'),
          mount(),
          button(
            p.opened.isNotEmpty && !complete ? 'Tiếp tục phục dựng' : 'Chơi',
            () => p.tutorialSeen ? go(PageId.map) : openTutorial(PageId.home),
            icon: Icons.play_arrow_rounded,
          ),
          navigation(
            'Bảo tàng',
            Icons.museum_outlined,
            () => go(PageId.museum),
          ),
          const Divider(height: 1),
          navigation('Cài đặt', Icons.tune, () => go(PageId.settings)),
        ];
      case PageId.tutorial:
        return [
          Tutorial(
            bone: level.bones.first,
            onContinue: leaveTutorial,
            exitLabel:
                tutorialOrigin == PageId.settings ? 'Về cài đặt' : 'Vào bản đồ',
          ),
        ];
      case PageId.map:
        return [
          title('Bản đồ khai quật'),
          mount(),
          ListTile(
            leading: const CircleAvatar(child: Text('01')),
            title: Text(level.name),
            subtitle: Text(
              p.best > 0
                  ? 'Kỷ lục ${p.best}/3 sao'
                  : '${p.placed.length}/${level.bones.length} mảnh đã ghép',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: resume,
          ),
        ];
      case PageId.crates:
        return [
          title('Mở thùng hóa thạch'),
          section(
            '${p.opened.length}/${level.crate.values.toSet().length} thùng đã mở',
          ),
          for (final id in level.crate.values.toSet())
            button(
              p.opened.contains(id)
                  ? 'Thùng $id đã mở'
                  : 'Mở thùng $id · ${level.crate.values.where((v) => v == id).length} mảnh',
              p.opened.contains(id)
                  ? null
                  : () {
                      save((n) => n.opened.add(id));
                    },
              icon: Icons.inventory_2_outlined,
            ),
          button(
            'Đến bàn ghép',
            p.opened.isEmpty ? null : () => go(PageId.play),
          ),
        ];
      case PageId.play:
        return [
          title(level.name),
          WorkProgress(p.placed.length, level.bones.length),
          AspectRatio(
            aspectRatio: level.size.aspectRatio,
            child: ClipRect(
              child: InteractiveViewer(
                transformationController: camera,
                minScale: 1,
                maxScale: 3,
                child: GestureDetector(
                  onTapUp: (details) {
                    final selected = tray.where((b) => b.id == selection);
                    if (selected.isNotEmpty)
                      drop(selected.first, details.globalPosition);
                  },
                  child: SizedBox.expand(
                    key: boardKey,
                    child: GameWidget(game: board),
                  ),
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => camera.value = Matrix4.identity(),
                child: const Text('Đặt lại góc nhìn'),
              ),
              TextButton(
                onPressed: p.used < level.free && tray.isNotEmpty ? hint : null,
                child: Text('Gợi ý (${level.free - p.used})'),
              ),
            ],
          ),
          if (tray.isNotEmpty) ...[
            section('Khay xương'),
            const Text(
              'Kéo mảnh vào bóng xương, hoặc chạm mảnh rồi chạm vị trí ghép.',
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in tray)
                Draggable<Bone>(
                  data: b,
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  maxSimultaneousDrags: 1,
                  onDragStarted: () => setState(() {
                    selection = b.id;
                    dragCancelled = false;
                  }),
                  onDragEnd: (d) {
                    if (!dragCancelled) drop(b, d.offset);
                  },
                  feedback: Transform.translate(
                    offset: const Offset(-36, -26),
                    child: piece(b, 72, 52),
                  ),
                  childWhenDragging: const SizedBox(width: 84, height: 76),
                  child: Listener(
                    onPointerCancel: (_) => dragCancelled = true,
                    child: InkWell(
                      onTap: () => setState(() => selection = b.id),
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: selection == b.id
                              ? Theme.of(context).colorScheme.secondaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHigh,
                          border: Border.all(
                            width: 2,
                            color: selection == b.id
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            piece(b, 66, 46),
                            Text(b.label, textAlign: TextAlign.center),
                            if (selection == b.id)
                              const Icon(Icons.check, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (level.rotation)
            button(
              'Xoay mảnh 15°',
              tray.any((b) => b.id == selection)
                  ? () {
                      save(
                        (n) => n.angles[selection!] =
                            (n.angles[selection!] ?? 0) + radians(15),
                      );
                    }
                  : null,
              icon: Icons.rotate_right,
            ),
          if (p.opened.length < level.crate.values.toSet().length)
            button(
              'Mở thùng còn lại',
              () => go(PageId.crates),
              icon: Icons.inventory_2,
            ),
        ];
      case PageId.victory:
        return [
          title('Phục dựng hoàn tất'),
          mount(),
          Text('${p.stars} / 3 sao · Kỷ lục ${p.best} sao'),
          Text('Ví hiện có ${p.coins} xu'),
          button('Xem hiện vật', () => go(PageId.museum), icon: Icons.museum),
          button('Ghép lại', () async {
            if (await save((n) => n.replay())) {
              camera.value = Matrix4.identity();
              selection = null;
              go(PageId.crates);
            }
          }),
        ];
      case PageId.museum:
        return [
          title('Bảo tàng'),
          if (p.best == 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Icon(Icons.museum_outlined, size: 64),
            ),
            section('Chưa có hiện vật'),
            const Text('Ghép đủ bốn mảnh T‑Rex để mở gian trưng bày đầu tiên.'),
            button(
              'Đến xưởng',
              () => p.tutorialSeen ? go(PageId.map) : openTutorial(PageId.home),
            ),
          ] else ...[
            mount(),
            Text('Hiện vật 01 · Kỷ lục ${p.best} sao'),
          ],
        ];
      case PageId.settings:
        return [
          title('Cài đặt'),
          button(
            'Tập ghép xương lại',
            () => openTutorial(PageId.settings),
            icon: Icons.school_outlined,
          ),
          SwitchListTile(
            title: const Text('Âm thanh khi ghép'),
            value: p.sound,
            onChanged: (v) => save((n) => n.sound = v),
          ),
          SwitchListTile(
            title: const Text('Rung khi ghép'),
            value: p.vibration,
            onChanged: (v) => save((n) => n.vibration = v),
          ),
        ];
    }
  }

  Widget piece(Bone b, double w, double h) => Transform.rotate(
        angle: p.angles[b.id] ?? 0,
        child: Image.asset(
          'assets/images/${b.asset}',
          width: w,
          height: h,
          fit: BoxFit.contain,
        ),
      );
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: page == PageId.home,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && !writing) back();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Fossil Unbox'),
            leading: page == PageId.home
                ? null
                : IconButton(
                    tooltip: 'Quay lại',
                    onPressed: writing ? null : back,
                    icon: const Icon(Icons.arrow_back),
                  ),
          ),
          body: !ready
              ? Center(
                  child: loadError == null
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(loadError!),
                            TextButton(
                              onPressed: load,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                )
              : SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: AbsorbPointer(
                        absorbing: writing,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: contents(),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      );
}
