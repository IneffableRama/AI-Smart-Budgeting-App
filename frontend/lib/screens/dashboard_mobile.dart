import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';
import '../models/budget_input.dart';
import 'dashboard_screen.dart' show kStreamlitBaseUrl;

/// Mobile (Android / iOS) dashboard — renders Streamlit in a WebView.
class MobileDashboard extends StatefulWidget {
  final BudgetInput input;
  const MobileDashboard({super.key, required this.input});

  @override
  State<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  WebViewController? _ctrl;
  bool _loading = true;
  bool _error   = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(MobileDashboard old) {
    super.didUpdateWidget(old);
    final newUrl = _buildUrl();
    if (newUrl != _currentUrl) _loadUrl(newUrl);
  }

  String _buildUrl() {
    if (!widget.input.hasData) return kStreamlitBaseUrl;
    return '$kStreamlitBaseUrl?${widget.input.toQueryString()}';
  }

  void _init() {
    final url = _buildUrl();
    _currentUrl = url;
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(SLColors.bg)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) =>
            setState(() { _loading = true; _error = false; }),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (_) =>
            setState(() { _loading = false; _error = true; }),
      ))
      ..loadRequest(Uri.parse(url));
  }

  void _loadUrl(String url) {
    _currentUrl = url;
    setState(() { _loading = true; _error = false; });
    _ctrl?.loadRequest(Uri.parse(url));
  }

  void _reload() => _loadUrl(_buildUrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.bg,
      body: SafeArea(
        child: Column(children: [
          _header(),
          if (widget.input.hasData) _successBanner(),
          Expanded(child: _body()),
        ]),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: SLColors.surface,
        border:
            Border(bottom: BorderSide(color: SLColors.border, width: 1)),
      ),
      child: Row(children: [
        const Text('💰', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('AI-Driven Smart Budgeting App',
              style: TextStyle(
                  color: SLColors.textPri,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
        if (widget.input.hasData)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: SLColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: SLColors.success.withOpacity(0.5)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, color: SLColors.success, size: 7),
              SizedBox(width: 5),
              Text('Live',
                  style: TextStyle(
                      color: SLColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        IconButton(
          onPressed: _reload,
          icon: const Icon(Icons.refresh_rounded,
              color: SLColors.textSec, size: 19),
          tooltip: 'Reload',
        ),
      ]),
    );
  }

  Widget _successBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: const BoxDecoration(
        color: Color(0xFF0B2016),
        border: Border(
          bottom: BorderSide(color: SLColors.border, width: 1),
          left: BorderSide(color: SLColors.success, width: 3),
        ),
      ),
      child: Row(children: [
        const Text('✅', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '📱 Inputs received — Income: ₹${widget.input.income?.toStringAsFixed(0) ?? "—"} | '
            'Age: ${widget.input.age ?? "—"} | Prediction running automatically ↓',
            style: const TextStyle(
                color: SLColors.textSec, fontSize: 11.5),
          ),
        ),
      ]),
    );
  }

  Widget _body() {
    if (_error) return _errorState();
    return Stack(children: [
      if (_ctrl != null) WebViewWidget(controller: _ctrl!),
      if (_loading) _loadingOverlay(),
    ]);
  }

  Widget _loadingOverlay() {
    return Container(
      color: SLColors.bg,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                color: SLColors.accent, strokeWidth: 2.5),
          ),
          const SizedBox(height: 14),
          Text(
            widget.input.hasData
                ? 'Sending inputs to Streamlit…'
                : 'Loading dashboard…',
            style: const TextStyle(
                color: SLColors.textSec, fontSize: 13),
          ),
        ]),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SLColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SLColors.border),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded,
                color: SLColors.textSec, size: 40),
            const SizedBox(height: 14),
            const Text('Could not load dashboard',
                style: TextStyle(
                    color: SLColors.textPri,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Make sure your Streamlit app is running and '
              'kStreamlitBaseUrl is set correctly in dashboard_screen.dart.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SLColors.textSec, fontSize: 12.5),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SLColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              onPressed: _reload,
              child: const Text('Try Again',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }
}
