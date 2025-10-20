import 'dart:io';

import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart' as webview_win;

class WebviewDesktop extends StatefulWidget {
  final Control control;
  final FletControlBackend backend;
  final Color? bgcolor;

  const WebviewDesktop({
    Key? key,
    required this.control,
    required this.backend,
    this.bgcolor,
  }) : super(key: key);

  @override
  State<WebviewDesktop> createState() => _WebviewDesktopState();
}

class _WebviewDesktopState extends State<WebviewDesktop> {
  final webview_win.WebviewController _controller =
      webview_win.WebviewController();
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Check if running on Windows
      if (!Platform.isWindows) {
        setState(() {
          _errorMessage = "Webview is only supported on Windows platform.";
        });
        return;
      }

      await _controller.initialize();

      // Set up event listeners
      _controller.loadingState.listen((state) {
        if (state == webview_win.LoadingState.loading) {
          widget.backend.triggerControlEvent(
              widget.control.id, "page_started", _controller.url.value);
        } else if (state == webview_win.LoadingState.navigationCompleted) {
          widget.backend.triggerControlEvent(
              widget.control.id, "page_ended", _controller.url.value);
        }
      });

      _controller.url.listen((url) {
        widget.backend.triggerControlEvent(widget.control.id, "url_change", url);
      });

      // Set background color if provided
      if (widget.bgcolor != null) {
        await _controller.setBackgroundColor(widget.bgcolor!);
      }

      // Load initial URL
      String url = widget.control.attrString("url", "https://flet.dev")!;
      await _controller.loadUrl(url);

      // Subscribe to backend methods
      widget.backend.subscribeMethods(widget.control.id,
          (methodName, args) async {
        switch (methodName) {
          case "reload":
            await _controller.reload();
            break;
          case "can_go_back":
            return _controller.canGoBack().toString();
          case "can_go_forward":
            return _controller.canGoForward().toString();
          case "go_back":
            if (await _controller.canGoBack()) {
              await _controller.goBack();
            }
            break;
          case "go_forward":
            if (await _controller.canGoForward()) {
              await _controller.goForward();
            }
            break;
          case "clear_cache":
            await _controller.clearCache();
            break;
          case "clear_local_storage":
            await _controller.clearCookies();
            break;
          case "get_current_url":
            return _controller.url.value;
          case "get_title":
            return await _controller.getTitle();
          case "load_request":
            var url = args["url"];
            if (url != null) {
              await _controller.loadUrl(url);
            }
            break;
          case "run_javascript":
            var javascript = args["value"];
            if (javascript != null) {
              await _controller.executeScript(javascript);
            }
            break;
          case "load_html":
            var html = args["value"];
            if (html != null) {
              await _controller.loadStringContent(html);
            }
            break;
          case "set_javascript_mode":
            // JavaScript is enabled by default in webview_windows
            // This is a no-op for compatibility
            break;
        }
        return null;
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize WebView: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return ErrorControl(_errorMessage!);
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return webview_win.Webview(_controller);
  }
}
