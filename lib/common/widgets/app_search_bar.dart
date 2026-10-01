// lib/common/widgets/app_search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  /// Fires when the user submits (keyboard "Search" key). Use this for
  /// API-backed search instead of `onChanged`.
  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  /// Optional external padding. Defaults to `EdgeInsets.symmetric(horizontal: 16)`.
  final EdgeInsetsGeometry? padding;

  /// Show a `×` button when the field has text. Defaults to `true`.
  final bool showClearButton;

  const AppSearchBar({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.controller,
    this.padding,
    this.showClearButton = true,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _hasText = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _focusNode = FocusNode()
      ..addListener(() {
        if (mounted) setState(() => _focused = _focusNode.hasFocus);
      });
    _controller.addListener(_onControllerChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  void _onControllerChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText && mounted) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _clear() {
    HapticFeedback.selectionClick();
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12);

    final borderColor = _focused
        ? cs.primary.withValues(alpha: 0.7)
        : cs.outlineVariant.withValues(alpha: 0.5);

    return Padding(
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ── Search field ─────────────────────────────────────────────
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: radius,
                border: Border.all(
                  color: borderColor,
                  width: _focused ? 1.4 : 1,
                ),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: cs.onSurface.withValues(alpha: 0.45),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      onSubmitted: widget.onSubmitted,
                      textInputAction: TextInputAction.search,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                      cursorColor: cs.primary,
                      cursorWidth: 1.6,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  // Clear button (only when there's text)
                  if (widget.showClearButton && _hasText)
                    _ClearButton(onTap: _clear),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // ── Filter button ────────────────────────────────────────────
          if (widget.onFilterTap != null) ...[
            const SizedBox(width: 10),
            _FilterButton(onTap: widget.onFilterTap!),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ClearButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Clear search',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.onSurface.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: cs.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FilterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Filter',
      child: Material(
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(
                Icons.tune_rounded,
                size: 22,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
