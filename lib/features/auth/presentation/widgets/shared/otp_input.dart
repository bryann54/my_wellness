import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_wellness/common/res/app_spacing.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.autofocus = true,
    this.enabled = true,
    this.hasError = false,
    this.onChanged,
    this.onCompleted,
  });

  final int length;
  final bool autofocus;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get value => _controllers.map((c) => c.text).join();

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (mounted) setState(() {});
    _nodes.first.requestFocus();
    widget.onChanged?.call('');
  }

  void _emit() {
    final v = value;
    widget.onChanged?.call(v);
    if (v.length == widget.length && !v.contains('')) {
      widget.onCompleted?.call(v);
    }
  }

  void _onChanged(int index, String raw) {
    if (raw.length > 1) {
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        final src = index + i;
        if (src >= widget.length || i >= digits.length) break;
        _controllers[src].text = digits[i];
      }
      final lastFilled = (index + digits.length - 1).clamp(
        0,
        widget.length - 1,
      );
      _nodes[lastFilled].requestFocus();
      setState(() {});
      _emit();
      return;
    }

    setState(() {});
    _emit();

    if (raw.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
      setState(() {});
      _emit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) {
        final filled = _controllers[i].text.isNotEmpty;
        final focused = _nodes[i].hasFocus;

        final borderColor = widget.hasError
            ? cs.error
            : focused
            ? cs.primary
            : filled
            ? cs.primary.withValues(alpha: 0.55)
            : cs.outline.withValues(alpha: 0.45);

        return SizedBox(
          width: 48,
          height: 56,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => _onKey(i, e),
            child: TextField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              enabled: widget.enabled,
              autofocus: widget.autofocus && i == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: i == widget.length ~/ 2 - 1 ? '–' : '',
                hintStyle: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.30),
                  fontWeight: FontWeight.w700,
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: cs.surfaceContainerLow,
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(color: borderColor, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(color: borderColor, width: 1.8),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(
                    color: cs.outline.withValues(alpha: 0.25),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(color: cs.error, width: 1.2),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          ),
        );
      }),
    );
  }
}
