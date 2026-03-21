import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../models/budget_input.dart';

// On mobile we use WebView; on web we use url_launcher.
// Import is conditional to avoid webview_flutter crashing on web builds.
import 'dashboard_mobile.dart'
    if (dart.library.html) 'dashboard_web_stub.dart';

/// Entry point — picks the right implementation at runtime.
class DashboardScreen extends StatelessWidget {
  final BudgetInput input;
  const DashboardScreen({super.key, required this.input});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _WebDashboard(input: input);
    }
    return MobileDashboard(input: input);
  }
}

// ── Web dashboard — opens Streamlit in a new browser tab ──────────────────────
class _WebDashboard extends StatelessWidget {
  final BudgetInput input;
  const _WebDashboard({required this.input});

  String _buildUrl() {
    const base = kStreamlitBaseUrl;
    if (!input.hasData) return base;
    return '$base?${input.toQueryString()}';
  }

  Future<void> _launch() async {
    final uri = Uri.parse(_buildUrl());
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.bg,
      body: SafeArea(
        child: Column(children: [
          _header(),
          if (input.hasData) _successBanner(),
          Expanded(child: _body(context)),
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
        if (input.hasData)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: SLColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: SLColors.success.withOpacity(0.5)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, color: SLColors.success, size: 7),
              SizedBox(width: 5),
              Text('Ready',
                  style: TextStyle(
                      color: SLColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ]),
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
            'Inputs ready — Income: ₹${input.income?.toStringAsFixed(0) ?? "—"} | '
            'Age: ${input.age ?? "—"} | '
            'Tap the button below to open the full AI dashboard.',
            style:
                const TextStyle(color: SLColors.textSec, fontSize: 12),
          ),
        ),
      ]),
    );
  }

  Widget _body(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streamlit logo placeholder
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: SLColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: SLColors.accent.withOpacity(0.3)),
              ),
              child: const Center(
                  child: Text('📊', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 20),
            const Text('Open AI Dashboard',
                style: TextStyle(
                    color: SLColors.textPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(
              input.hasData
                  ? 'Your inputs are ready. The dashboard will open in a new tab '
                    'with all fields pre-filled and prediction running automatically.'
                  : 'Submit the Input form first to pre-fill the dashboard, '
                    'or open it directly to enter values manually.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: SLColors.textSec, fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 28),

            // Primary CTA
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SLColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                onPressed: _launch,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new_rounded, size: 17),
                    const SizedBox(width: 8),
                    Text(input.hasData
                        ? 'Open Dashboard with My Inputs'
                        : 'Open Dashboard'),
                  ],
                ),
              ),
            ),

            if (input.hasData) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: SLColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SLColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INPUT SUMMARY',
                        style: TextStyle(
                            color: SLColors.textSec,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                    const SizedBox(height: 10),
                    _summaryGrid([
                      ('Income', '₹${input.income?.toStringAsFixed(0) ?? "—"}'),
                      ('Age', '${input.age ?? "—"}'),
                      ('Dependents', '${input.dependents ?? "—"}'),
                      ('Occupation', input.occupationLabel),
                      ('City', input.cityTierLabel),
                      ('Savings %', '${input.desiredSavingsPercentage?.toStringAsFixed(0) ?? "—"}%'),
                    ]),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryGrid(List<(String, String)> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: SLColors.surface2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: SLColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$1,
                  style: const TextStyle(
                      color: SLColors.textSec,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(item.$2,
                  style: const TextStyle(
                      color: SLColors.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

const String kStreamlitBaseUrl = 'https://ai-smart-budgeting-app-qtfme5dtqy47b84vabbuqr.streamlit.app/';
