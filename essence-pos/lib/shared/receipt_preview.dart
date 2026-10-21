import 'package:flutter/material.dart';
import 'package:qr/qr.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/theme/tokens.dart';
import '../core/printing/receipt_doc.dart';

/// Renders a [ReceiptDoc] as a paper receipt, character-for-character like the printer.
class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({super.key, required this.doc, this.columns = 48, this.maxWidth = 380});
  final ReceiptDoc doc;
  final int columns;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return LayoutBuilder(builder: (context, c) {
      final width = (c.maxWidth.isFinite ? c.maxWidth : maxWidth).clamp(220.0, maxWidth);
      // Monospace glyph advance is ~0.6em; fit `columns` characters in the paper width.
      final fontSize = ((width - 32) / columns / 0.6).clamp(7.0, 13.0);
      final base = TextStyle(fontFamily: 'JetBrainsMono', fontSize: fontSize, height: 1.35, color: ec.ink);
      final children = <Widget>[];
      for (final l in doc.lines) {
        switch (l) {
          case RText():
            final size = l.big ? fontSize * 1.9 : (l.tall ? fontSize * 1.5 : fontSize);
            final cols = l.big ? columns ~/ 2 : columns;
            for (final line in wrapText(l.text, cols)) {
              final text = Text(
                line,
                textAlign: switch (l.align) { RAlign.left => TextAlign.left, RAlign.center => TextAlign.center, RAlign.right => TextAlign.right },
                style: base.copyWith(fontSize: size, fontWeight: l.bold || l.big ? FontWeight.w600 : FontWeight.w400, height: l.big ? 1.15 : 1.35),
              );
              final link = l.link;
              children.add(link == null
                  ? text
                  : MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
                        child: text,
                      ),
                    ));
            }
          case RRow():
            for (final line in layoutRow(l.left, l.right, columns, indent: l.indent)) {
              children.add(Text(line,
                  style: base.copyWith(fontWeight: l.bold ? FontWeight.w600 : FontWeight.w400, fontSize: l.tall ? fontSize * 1.35 : fontSize),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false));
            }
          case RDivider():
            children.add(Text(l.char * columns, style: base.copyWith(color: ec.ink.withValues(alpha: 0.55)), maxLines: 1, softWrap: false, overflow: TextOverflow.clip));
          case RQr():
            children.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(child: SizedBox(width: 108, height: 108, child: QrView(data: l.data, color: ec.ink))),
            ));
          case RLogo():
            children.add(Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Center(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.33, 0.33, 0.33, 0, 0, //
                    0.33, 0.33, 0.33, 0, 0,
                    0.33, 0.33, 0.33, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
                  child: Image.asset('assets/images/logo.png', width: width * 0.42),
                ),
              ),
            ));
          case RFeed():
            children.add(SizedBox(height: fontSize * 1.3 * l.lines));
        }
      }
      return Center(
        child: Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
          decoration: BoxDecoration(
            color: ec.paper,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [BoxShadow(color: ec.shadow, blurRadius: 18, offset: const Offset(0, 6))],
          ),
          child: DefaultTextStyle(
            style: base,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: width - 32,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class QrView extends StatelessWidget {
  const QrView({super.key, required this.data, required this.color});
  final String data;
  final Color color;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _QrPainter(data, color), size: Size.infinite);
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data, this.color);
  final String data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final qr = QrImage(QrCode(payload: QrPayload.fromString(data)));
    final n = qr.moduleCount;
    final cell = size.shortestSide / n;
    final paint = Paint()..color = color;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (qr.isDark(r, c)) canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell + 0.3, cell + 0.3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.data != data || old.color != color;
}
