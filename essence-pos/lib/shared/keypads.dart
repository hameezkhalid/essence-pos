import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme/tokens.dart';

/// 4-digit PIN entry with on-screen keys and hardware keyboard support.
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onComplete, this.length = 4, this.error, this.busy = false});
  final Future<bool> Function(String pin) onComplete;
  final int length;
  final String? error;
  final bool busy;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _wrong = false;
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  final _focus = FocusNode();

  @override
  void dispose() {
    _shake.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _press(String d) async {
    if (widget.busy || _pin.length >= widget.length) return;
    setState(() {
      _pin += d;
      _wrong = false;
    });
    if (_pin.length == widget.length) {
      final ok = await widget.onComplete(_pin);
      if (!mounted) return;
      if (!ok) {
        HapticFeedback.heavyImpact();
        _shake.forward(from: 0);
        setState(() {
          _wrong = true;
          _pin = '';
        });
      } else {
        setState(() => _pin = '');
      }
    }
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return KeyboardListener(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        final ch = e.character;
        if (ch != null && RegExp(r'^\d$').hasMatch(ch)) _press(ch);
        if (e.logicalKey == LogicalKeyboardKey.backspace) _back();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _shake,
            builder: (context, child) {
              final t = _shake.value;
              final dx = t == 0 ? 0.0 : 10 * (1 - t) * (((t * 10).floor().isEven) ? 1 : -1);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _pin.length ? (_wrong ? ec.danger : ec.primary) : Colors.transparent,
                      border: Border.all(color: _wrong ? ec.danger : (i < _pin.length ? ec.primary : ec.textFaint), width: 2),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 28,
            child: Center(
              child: Text(
                _wrong ? (widget.error ?? 'Wrong PIN, try again') : '',
                style: context.tt.bodySmall?.copyWith(color: ec.danger, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', '<'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final k in row)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: k.isEmpty
                          ? const SizedBox(width: 72, height: 64)
                          : _Key(
                              label: k,
                              onTap: k == '<' ? _back : () => _press(k),
                              icon: k == '<' ? Icons.backspace_outlined : null,
                            ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, this.icon});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    return Material(
      color: icon != null ? Colors.transparent : ec.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: icon != null ? Colors.transparent : ec.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 72,
          height: 64,
          child: Center(
            child: icon != null
                ? Icon(icon, color: ec.textMuted, semanticLabel: 'Delete')
                : Text(label, style: context.tt.headlineSmall?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

/// Numeric keypad for amounts. Edits a rupee string.
class AmountPad extends StatelessWidget {
  const AmountPad({super.key, required this.value, required this.onChanged, this.allowDecimal = false});
  final String value;
  final ValueChanged<String> onChanged;
  final bool allowDecimal;

  void _tap(String k) {
    if (k == '<') {
      onChanged(value.isEmpty ? '' : value.substring(0, value.length - 1));
    } else if (k == 'C') {
      onChanged('');
    } else if (k == '.') {
      if (allowDecimal && !value.contains('.')) onChanged(value.isEmpty ? '0.' : '$value.');
    } else {
      if (value.replaceAll('.', '').length >= 9) return;
      onChanged(value == '0' ? k : '$value$k');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      [allowDecimal ? '.' : 'C', '0', '<'],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              for (final k in row)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: k == '<' || k == 'C' ? ec.surfaceAlt : ec.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rad.md), side: BorderSide(color: ec.border)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(Rad.md),
                        onTap: () => _tap(k),
                        child: SizedBox(
                          height: 54,
                          child: Center(
                            child: k == '<'
                                ? Icon(Icons.backspace_outlined, color: ec.textMuted, size: 20)
                                : Text(k, style: context.tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
          ),
      ],
    );
  }
}
