import 'package:flutter/material.dart';
import '../models/budget_input.dart';

/// Stub — on web, DashboardScreen uses _WebDashboard directly.
/// This file satisfies the conditional import; it is never instantiated.
class MobileDashboard extends StatelessWidget {
  final BudgetInput input;
  const MobileDashboard({super.key, required this.input});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
