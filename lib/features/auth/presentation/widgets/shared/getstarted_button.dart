// // lib/features/auth/presentation/widgets/getstarted_button.dart
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:my_wellness/common/helpers/app_router.gr.dart';

// class GetStartedButton extends StatefulWidget {
//   final String text;
//   final Color? backgroundColor;
//   final Color? textColor;
//   final PageRouteInfo? route;
//   final VoidCallback? onPressed;
//   final IconData? icon;
//   final String? imagePath;

//   const GetStartedButton({
//     super.key,
//     required this.text,
//     this.backgroundColor,
//     this.textColor,
//     this.route,
//     this.onPressed,
//     this.icon,
//     this.imagePath,
//   });

//   bool get _isDisabled => onPressed == null && route == null;

//   @override
//   State<GetStartedButton> createState() => _GetStartedButtonState();
// }

// class _GetStartedButtonState extends State<GetStartedButton>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 120),
//     );
//     _scale = Tween<double>(
//       begin: 1.0,
//       end: 0.97,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _handleTap() async {
//     if (widget._isDisabled) return;
//     HapticFeedback.lightImpact();
//     await _controller.forward();
//     await _controller.reverse();
//     if (!mounted) return;
//     if (widget.onPressed != null) {
//       widget.onPressed!();
//     } else {
//       context.router.replace(widget.route ?? const LoginRoute());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final disabled = widget._isDisabled;

//     final bg = disabled
//         ? cs.onSurface.withValues(alpha: 0.12)
//         : (widget.backgroundColor ?? cs.onSurface);
//     final fg = disabled
//         ? cs.onSurface.withValues(alpha: 0.35)
//         : (widget.textColor ?? cs.surface);

//     return GestureDetector(
//       onTapDown: disabled ? null : (_) => _controller.forward(),
//       onTapUp: disabled
//           ? null
//           : (_) {
//               _controller.reverse();
//               _handleTap();
//             },
//       onTapCancel: disabled ? null : () => _controller.reverse(),
//       child: ScaleTransition(
//         scale: _scale,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeOut,
//             height: 54,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: bg,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Center(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (widget.imagePath != null) ...[
//                     Image.asset(widget.imagePath!, height: 20, width: 20),
//                     const SizedBox(width: 10),
//                   ],
//                   AnimatedDefaultTextStyle(
//                     duration: const Duration(milliseconds: 250),
//                     style: GoogleFonts.syne(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: fg,
//                       letterSpacing: 0.3,
//                     ),
//                     child: Text(widget.text),
//                   ),
//                   if (widget.icon != null) ...[
//                     const SizedBox(width: 10),
//                     AnimatedOpacity(
//                       opacity: disabled ? 0.35 : 1.0,
//                       duration: const Duration(milliseconds: 250),
//                       child: Icon(widget.icon, color: fg, size: 18),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
