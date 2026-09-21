import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:my_wellness/common/res/l10n.dart';
import 'package:my_wellness/common/widgets/appbar/custom_app_bar.dart';
import 'package:my_wellness/common/widgets/empty_state_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  int _loadingProgress = 0;
  bool _hasError = false;
  String? _errorMessage;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _loadingProgress = progress);
          },
          onPageStarted: (url) {
            setState(() {
              _hasError = false;
              _loadingProgress = 0;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
            });
            debugPrint('WebView error: $error');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _loadingProgress = 0;
    });
    _initWebView(); // reinitialize controller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppBar(
            title: widget.title,
            isHome: false,
            //
          ),
          SliverFillRemaining(
            child: _hasError
                ? EmptyStateView(
                    imagePath: 'assets/images/error.png',
                    floatingIcon: Icons.error_outline,
                    title: AppLocalizations.getString(context, 'common.error'),
                    subtitle:
                        _errorMessage ??
                        AppLocalizations.getString(
                          context,
                          'webview.failedToLoad',
                        ),
                    buttonLabel: AppLocalizations.getString(
                      context,
                      'profile.retry',
                    ),
                    onButtonPressed: _retry,
                  )
                : Stack(
                    children: [
                      WebViewWidget(controller: _controller),
                      if (_loadingProgress < 100 && _loadingProgress > 0)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            value: _loadingProgress / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
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
