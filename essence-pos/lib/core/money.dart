import 'package:intl/intl.dart';

/// All money in the app is an integer number of paisa (1 Rs = 100 paisa).
typedef Paisa = int;

final _whole = NumberFormat('#,##0', 'en_US');
final _decimal = NumberFormat('#,##0.00', 'en_US');

/// Formats paisa as rupees: `Rs 1,850` (decimals only when there are paisa).
String rs(Paisa p, {bool symbol = true}) {
  final neg = p < 0;
  final abs = p.abs();
  final text = abs % 100 == 0 ? _whole.format(abs ~/ 100) : _decimal.format(abs / 100);
  return '${neg ? '−' : ''}${symbol ? 'Rs ' : ''}$text';
}

/// Formats paisa without the currency symbol: `1,850`.
String num0(Paisa p) => rs(p, symbol: false);

/// Rupees (as typed by a user) to paisa.
Paisa paisaFromRupees(num rupees) => (rupees * 100).round();

/// Parses user input such as "1,250" or "1250.50" into paisa. Returns null when invalid.
Paisa? parseRupees(String input) {
  final cleaned = input.replaceAll(',', '').replaceAll('Rs', '').trim();
  if (cleaned.isEmpty) return null;
  final v = double.tryParse(cleaned);
  if (v == null || v.isNaN || v.isInfinite) return null;
  return paisaFromRupees(v);
}

/// Rounds a paisa value (possibly fractional) to the nearest whole rupee, half up.
Paisa roundToRupee(num paisa) {
  final r = (paisa / 100);
  return (r >= 0 ? (r + 0.5).floor() : -((-r + 0.5).floor())) * 100;
}

/// Rounds paisa to the nearest [step] rupees (1, 5, 10), half up.
Paisa roundToStep(Paisa paisa, int stepRupees) {
  if (stepRupees <= 0) return paisa;
  final step = stepRupees * 100;
  return ((paisa + step / 2) ~/ step) * step;
}

/// Basis points (1500 = 15%) as a display string: `15%`, `7.5%`.
String pct(int basisPoints) {
  final v = basisPoints / 100;
  return v == v.roundToDouble() ? '${v.toInt()}%' : '${v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '')}%';
}
