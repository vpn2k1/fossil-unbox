import 'package:flutter/material.dart';

const pine = Color(0xff244c40);
const parchment = Color(0xfff7f3e9);
const brass = Color(0xffe6c386);
const slate = Color(0xff1e3029);

ThemeData workshopTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme =
      ColorScheme.fromSeed(seedColor: pine, brightness: brightness).copyWith(
    primary: dark ? const Color(0xffa8d7bf) : pine,
    surface: dark ? const Color(0xff19221e) : parchment,
  );
  final base =
      ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: "Roboto");
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: "Roboto",
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    textTheme: base.textTheme.copyWith(
      headlineMedium: TextStyle(
        fontFamily: 'serif',
        fontSize: 34,
        height: 1.15,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
          fontFamily: "Roboto",
          fontSize: 16,
          height: 1.4,
          color: scheme.onSurface),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}

/// A specimen mount with an engraved measuring rule and registration corners.
class SpecimenMount extends StatelessWidget {
  const SpecimenMount({
    super.key,
    required this.specimen,
    required this.caption,
  });
  final Widget specimen;
  final String caption;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: slate,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomPaint(
              painter: const _MountMarks(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExcludeSemantics(child: specimen),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xff536258))),
              ),
              child: Text(
                caption,
                style: const TextStyle(
                  color: brass,
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
}

class _MountMarks extends CustomPainter {
  const _MountMarks();
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = const Color(0xff647567)
      ..strokeWidth = 1;
    for (double x = 16; x < size.width - 16; x += 8) {
      final major = ((x - 16) / 8).round() % 5 == 0;
      canvas.drawLine(Offset(x, 0), Offset(x, major ? 9 : 4), pen);
    }
    for (final x in [16.0, size.width - 16]) {
      for (final y in [20.0, size.height - 12]) {
        canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), pen);
        canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), pen);
      }
    }
  }

  @override
  bool shouldRepaint(_MountMarks other) => false;
}

class WorkProgress extends StatelessWidget {
  const WorkProgress(this.done, this.total, {super.key});
  final int done, total;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đã ghép $done/$total mảnh',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: done / total,
              minHeight: 6,
              semanticsLabel: 'Tiến trình phục dựng',
              semanticsValue: '$done trên $total',
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
}
