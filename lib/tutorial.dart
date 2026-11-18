import 'package:flutter/material.dart';
import 'model.dart';

// Practice stays local to this screen. Only leaving the tutorial marks it seen.
class Tutorial extends StatefulWidget {
  const Tutorial({
    super.key,
    required this.bone,
    required this.onContinue,
    this.exitLabel = 'Vào bản đồ',
  });
  final Bone bone;
  final String exitLabel;
  final VoidCallback onContinue;

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  bool opened = false;
  bool placed = false;
  bool missed = false;
  bool selected = false;
  void place() => setState(() {
        placed = true;
        missed = false;
        selected = false;
      });

  Widget sprite({bool outline = false}) => Image.asset(
        'assets/images/${widget.bone.asset}',
        width: 112,
        height: 64,
        color: outline ? const Color(0xffa89576) : null,
        colorBlendMode: outline ? BlendMode.srcIn : null,
        excludeFromSemantics: true,
      );

  @override
  Widget build(BuildContext context) {
    final label = widget.bone.label.toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Buổi tập đầu tiên',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: placed
              ? 1
              : opened
                  ? 0.5
                  : 0,
          semanticsLabel: 'Tiến trình bài tập',
        ),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Text(
            placed
                ? 'Đã khớp! Trong màn T‑Rex, hãy ghép đủ bốn mảnh để đưa bộ xương vào bảo tàng.'
                : opened
                    ? (selected
                        ? 'Chạm bóng xương phía trên để ghép.'
                        : 'Kéo mảnh $label vào bóng xương, hoặc chạm mảnh rồi chạm bóng.')
                    : 'Chạm thùng để lấy mảnh xương đầu tiên.',
          ),
        ),
        const SizedBox(height: 16),
        if (!opened) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Icon(Icons.inventory_2_outlined, size: 64),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Mở thùng tập'),
            onPressed: () => setState(() => opened = true),
          ),
        ] else ...[
          Center(
            child: DragTarget<String>(
              onWillAcceptWithDetails: (d) =>
                  !placed && d.data == widget.bone.id,
              onAcceptWithDetails: (_) => place(),
              builder: (_, candidates, __) => Semantics(
                label: 'Vị trí ghép $label',
                child: InkWell(
                  onTap: selected ? place : null,
                  child: Container(
                    width: 144,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: candidates.isEmpty
                          ? const Color(0xfff4e9d2)
                          : const Color(0xffffd897),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: sprite(outline: !placed),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!placed)
            Center(
              child: Draggable<String>(
                data: widget.bone.id,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                maxSimultaneousDrags: 1,
                feedback: Transform.translate(
                  offset: const Offset(-56, -32),
                  child: sprite(),
                ),
                childWhenDragging: const SizedBox(width: 112, height: 64),
                onDragEnd: (d) {
                  if (mounted && !d.wasAccepted) setState(() => missed = true);
                },
                child: Semantics(
                  label: 'Mảnh $label trong khay',
                  selected: selected,
                  child: InkWell(
                    onTap: () => setState(() => selected = true),
                    child: sprite(),
                  ),
                ),
              ),
            ),
          if (missed)
            const Text('Mảnh đã về khay. Thử thả khi ô bóng xương sáng lên.'),
        ],
        const SizedBox(height: 16),
        if (placed)
          FilledButton(
            onPressed: widget.onContinue,
            child: Text(widget.exitLabel),
          )
        else
          TextButton(
            onPressed: widget.onContinue,
            child: const Text('Bỏ qua hướng dẫn'),
          ),
      ],
    );
  }
}
