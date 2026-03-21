import 'package:flutter/material.dart';
import 'screens/budget_form_screen.dart';
import 'screens/dashboard_screen.dart';
import 'models/budget_input.dart';

void main() {
  runApp(const BudgetOptimizerApp());
}

class BudgetOptimizerApp extends StatelessWidget {
  const BudgetOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Smart Budgeting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: SLColors.bg,
        colorScheme: const ColorScheme.dark(
          surface: SLColors.surface,
          primary: SLColors.accent,
        ),
      ),
      home: const RootNavigator(),
    );
  }
}

// ── Shared color palette (Streamlit-matched) ──────────────────────────────────
class SLColors {
  static const bg       = Color(0xFF0E1117);
  static const surface  = Color(0xFF1A1D27);
  static const surface2 = Color(0xFF262730);
  static const border   = Color(0xFF2C2F3E);
  static const accent   = Color(0xFF1F77B4); // Plotly default blue
  static const teal     = Color(0xFF17BECF); // Plotly teal
  static const orange   = Color(0xFFFF7F0E); // Plotly orange
  static const textPri  = Color(0xFFFAFAFA);
  static const textSec  = Color(0xFFA3A8B8);
  static const textHint = Color(0xFF545868);
  static const success  = Color(0xFF21C55D); // st.success
  static const error    = Color(0xFFFF4B4B);
}

// ── Root navigator ────────────────────────────────────────────────────────────
class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  final BudgetInput _shared = BudgetInput();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) setState(() => _tab = _tabCtrl.index);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _onFormSubmitted(BudgetInput input) {
    setState(() {
      _shared.copyFrom(input);
      _tab = 1;
      _tabCtrl.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.bg,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: SLColors.surface,
          border: Border(top: BorderSide(color: SLColors.border, width: 1)),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicatorColor: SLColors.accent,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: SLColors.accent,
          unselectedLabelColor: SLColors.textSec,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(icon: Icon(Icons.input_rounded, size: 20), text: 'Input'),
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 20), text: 'Dashboard'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          BudgetFormScreen(onSubmit: _onFormSubmitted),
          DashboardScreen(input: _shared),
        ],
      ),
    );
  }
}
