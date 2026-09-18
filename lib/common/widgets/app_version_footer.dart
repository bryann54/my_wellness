// lib/common/widgets/app_version_footer.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionFooter extends StatefulWidget {
  const AppVersionFooter({super.key});

  @override
  State<AppVersionFooter> createState() => _AppVersionFooterState();
}

class _AppVersionFooterState extends State<AppVersionFooter> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = 'v${info.version} (${info.buildNumber})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_version.isEmpty) return const SizedBox.shrink();

    return Text(
      _version,
      style: GoogleFonts.acme(
        fontSize: 11,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
      ),
    );
  }
}
