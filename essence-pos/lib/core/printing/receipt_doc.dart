/// A printer-independent description of a printed document. The same document is
/// rendered to ESC/POS bytes for the thermal printer and to a widget for on-screen preview,
/// so what the cashier sees is exactly what prints.
library;

enum RAlign { left, center, right }

sealed class RLine {
  const RLine();
}

class RText extends RLine {
  const RText(this.text, {this.align = RAlign.left, this.bold = false, this.big = false, this.tall = false});
  final String text;
  final RAlign align;
  final bool bold;

  /// Double width and height.
  final bool big;

  /// Double height only.
  final bool tall;
}

/// Left text and right-aligned text on one line (left wraps if needed).
class RRow extends RLine {
  const RRow(this.left, this.right, {this.bold = false, this.tall = false, this.indent = 0});
  final String left;
  final String right;
  final bool bold;
  final bool tall;
  final int indent;
}

class RDivider extends RLine {
  const RDivider([this.char = '-']);
  final String char;
}

class RQr extends RLine {
  const RQr(this.data, {this.size = 6});
  final String data;
  final int size;
}

/// The store logo (rendered from assets/images/receipt_logo.png).
class RLogo extends RLine {
  const RLogo();
}

class RFeed extends RLine {
  const RFeed([this.lines = 1]);
  final int lines;
}

class ReceiptDoc {
  const ReceiptDoc(this.lines, {this.cut = true, this.openDrawer = false, this.title = 'Receipt'});
  final List<RLine> lines;
  final bool cut;
  final bool openDrawer;
  final String title;

  ReceiptDoc withDrawer(bool open) => ReceiptDoc(lines, cut: cut, openDrawer: open, title: title);
}

/// Replaces characters thermal printers can't print with ASCII equivalents.
String toPrintable(String s) {
  const map = {
    '·': '-', '—': '-', '–': '-', '−': '-', '×': 'x', '’': "'", '‘': "'", '“': '"', '”': '"', '…': '...',
    'é': 'e', 'è': 'e', 'ê': 'e', 'à': 'a', 'â': 'a', 'ç': 'c', 'ô': 'o', 'û': 'u', 'ï': 'i', 'î': 'i',
    'É': 'E', '✓': 'v', '•': '*', '₨': 'Rs', ' ': ' ',
  };
  final b = StringBuffer();
  for (final ch in s.runes) {
    final c = String.fromCharCode(ch);
    if (map.containsKey(c)) {
      b.write(map[c]);
    } else if (ch >= 32 && ch < 127 || ch == 10) {
      b.write(c);
    } else {
      b.write('?');
    }
  }
  return b.toString();
}

/// Wraps [text] to [width] columns on word boundaries.
List<String> wrapText(String text, int width) {
  if (width <= 0) return [text];
  final out = <String>[];
  for (final para in text.split('\n')) {
    var line = '';
    for (final word in para.split(' ')) {
      var w = word;
      while (w.length > width) {
        if (line.isNotEmpty) {
          out.add(line);
          line = '';
        }
        out.add(w.substring(0, width));
        w = w.substring(width);
      }
      if (line.isEmpty) {
        line = w;
      } else if (line.length + 1 + w.length <= width) {
        line = '$line $w';
      } else {
        out.add(line);
        line = w;
      }
    }
    out.add(line);
  }
  return out;
}

/// Lays out a left/right row into one or more fixed-width lines.
List<String> layoutRow(String left, String right, int width, {int indent = 0}) {
  final pad = ' ' * indent;
  final avail = width - right.length - 1 - indent;
  if (avail < 6) return [...wrapText('$pad$left', width), right.padLeft(width)];
  final parts = wrapText(left, avail);
  final out = <String>[];
  for (var i = 0; i < parts.length; i++) {
    if (i == 0) {
      out.add('$pad${parts[i].padRight(avail)} ${right.padLeft(right.length)}'.padRight(width));
    } else {
      out.add('$pad  ${parts[i]}');
    }
  }
  return out;
}
