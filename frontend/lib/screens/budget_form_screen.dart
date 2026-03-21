import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/budget_input.dart';

class BudgetFormScreen extends StatefulWidget {
  final void Function(BudgetInput input) onSubmit;
  const BudgetFormScreen({super.key, required this.onSubmit});

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _input   = BudgetInput();
  late AnimationController _anim;
  late Animation<double>   _fade;

  // Controllers
  final _incomeCtrl            = TextEditingController();
  final _ageCtrl               = TextEditingController();
  final _dependentsCtrl        = TextEditingController();
  final _rentCtrl              = TextEditingController();
  final _loanCtrl              = TextEditingController();
  final _insuranceCtrl         = TextEditingController();
  final _groceriesCtrl         = TextEditingController();
  final _transportCtrl         = TextEditingController();
  final _eatingOutCtrl         = TextEditingController();
  final _entertainmentCtrl     = TextEditingController();
  final _utilitiesCtrl         = TextEditingController();
  final _healthcareCtrl        = TextEditingController();
  final _educationCtrl         = TextEditingController();
  final _miscCtrl              = TextEditingController();
  final _desiredSavingsPctCtrl = TextEditingController();
  final _desiredSavingsCtrl    = TextEditingController();
  final _disposableCtrl        = TextEditingController();

  String _occupation = 'Employed';
  String _cityTier   = 'Tier 1';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    for (final c in [
      _incomeCtrl, _ageCtrl, _dependentsCtrl, _rentCtrl, _loanCtrl,
      _insuranceCtrl, _groceriesCtrl, _transportCtrl, _eatingOutCtrl,
      _entertainmentCtrl, _utilitiesCtrl, _healthcareCtrl, _educationCtrl,
      _miscCtrl, _desiredSavingsPctCtrl, _desiredSavingsCtrl, _disposableCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _input.occupationRetired      = _occupation == 'Retired';
      _input.occupationSelfEmployed = _occupation == 'Self Employed';
      _input.occupationStudent      = _occupation == 'Student';
      _input.cityTier2              = _cityTier == 'Tier 2';
      _input.cityTier3              = _cityTier == 'Tier 3';
      widget.onSubmit(_input);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SLColors.bg,
      body: FadeTransition(
        opacity: _fade,
        child: CustomScrollView(
          slivers: [
            _appBar(),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoBanner(
                        'Fill in your financial profile. '
                        'Inputs are sent to the AI dashboard automatically.',
                      ),
                      const SizedBox(height: 20),

                      // PROFILE ──────────────────────────────────────────────
                      _sectionDivider('Profile'),
                      _card([
                        _field(_incomeCtrl,     'Income (₹)',    '50000', false,
                            (v) => _input.income = double.tryParse(v ?? '')),
                        _row([
                          _field(_ageCtrl,       'Age',          '28',    true,
                              (v) => _input.age = int.tryParse(v ?? '')),
                          _field(_dependentsCtrl,'Dependents',   '0',     true,
                              (v) => _input.dependents = int.tryParse(v ?? '')),
                        ]),
                      ]),

                      // OCCUPATION ───────────────────────────────────────────
                      _sectionDivider('Occupation'),
                      _card([_occupationPills()]),

                      // CITY TIER ────────────────────────────────────────────
                      _sectionDivider('City Tier'),
                      _card([_cityTierButtons()]),

                      // FIXED EXPENSES ───────────────────────────────────────
                      _sectionDivider('Fixed Expenses'),
                      _card([
                        _field(_rentCtrl,    'Rent (₹)',           '10000', false,
                            (v) => _input.rent = double.tryParse(v ?? '')),
                        _field(_loanCtrl,    'Loan Repayment (₹)', '5000',  false,
                            (v) => _input.loanRepayment = double.tryParse(v ?? '')),
                        _field(_insuranceCtrl,'Insurance (₹)',     '2000',  false,
                            (v) => _input.insurance = double.tryParse(v ?? '')),
                      ]),

                      // VARIABLE EXPENSES ────────────────────────────────────
                      _sectionDivider('Variable Expenses'),
                      _card([
                        _expenseGrid([
                          _Exp(_groceriesCtrl,    'Groceries (₹)',
                              (v) => _input.groceries = double.tryParse(v ?? '')),
                          _Exp(_transportCtrl,    'Transport (₹)',
                              (v) => _input.transport = double.tryParse(v ?? '')),
                          _Exp(_eatingOutCtrl,    'Eating Out (₹)',
                              (v) => _input.eatingOut = double.tryParse(v ?? '')),
                          _Exp(_entertainmentCtrl,'Entertainment (₹)',
                              (v) => _input.entertainment = double.tryParse(v ?? '')),
                          _Exp(_utilitiesCtrl,    'Utilities (₹)',
                              (v) => _input.utilities = double.tryParse(v ?? '')),
                          _Exp(_healthcareCtrl,   'Healthcare (₹)',
                              (v) => _input.healthcare = double.tryParse(v ?? '')),
                          _Exp(_educationCtrl,    'Education (₹)',
                              (v) => _input.education = double.tryParse(v ?? '')),
                          _Exp(_miscCtrl,         'Miscellaneous (₹)',
                              (v) => _input.miscellaneous = double.tryParse(v ?? '')),
                        ]),
                      ]),

                      // SAVINGS TARGETS ──────────────────────────────────────
                      _sectionDivider('Savings Targets'),
                      _card([
                        _field(_desiredSavingsPctCtrl, 'Desired Savings %',    '20', false,
                            (v) => _input.desiredSavingsPercentage = double.tryParse(v ?? '')),
                        _field(_desiredSavingsCtrl,    'Desired Savings (₹)',  '0',  false,
                            (v) => _input.desiredSavings = double.tryParse(v ?? '')),
                        _field(_disposableCtrl,        'Disposable Income (₹)','0',  false,
                            (v) => _input.disposableIncome = double.tryParse(v ?? '')),
                      ]),

                      const SizedBox(height: 28),
                      _submitButton(),
                      const SizedBox(height: 56),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  SliverAppBar _appBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 110,
      backgroundColor: SLColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: SLColors.border),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: SLColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: SLColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                      child: Text('💰', style: TextStyle(fontSize: 15))),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('AI-Driven Smart Budgeting App',
                      style: TextStyle(
                          color: SLColors.textPri,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                ),
              ]),
              const SizedBox(height: 4),
              const Text(
                'Savings prediction, insights, and recommendations',
                style: TextStyle(color: SLColors.textSec, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Component helpers ──────────────────────────────────────────────────────

  Widget _infoBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F33),
        borderRadius: BorderRadius.circular(6),
        border: const Border(
            left: BorderSide(color: SLColors.accent, width: 3)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded,
            color: SLColors.accent, size: 15),
        const SizedBox(width: 9),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  color: SLColors.textSec, fontSize: 12.5)),
        ),
      ]),
    );
  }

  Widget _sectionDivider(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(children: [
        Expanded(child: Container(height: 1, color: SLColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  color: SLColors.textSec,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.9)),
        ),
        Expanded(child: Container(height: 1, color: SLColors.border)),
      ]),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: SLColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SLColors.border, width: 1),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      children: children
          .asMap()
          .entries
          .map((e) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: e.key > 0 ? 8 : 0),
                  child: e.value,
                ),
              ))
          .toList(),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    bool intOnly,
    void Function(String?) onSaved,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: SLColors.textSec,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          TextFormField(
            controller: ctrl,
            keyboardType:
                TextInputType.numberWithOptions(decimal: !intOnly),
            inputFormatters: [
              if (intOnly)
                FilteringTextInputFormatter.digitsOnly
              else
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onSaved: onSaved,
            style: const TextStyle(
                color: SLColors.textPri,
                fontSize: 13.5,
                fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: SLColors.textHint, fontSize: 13.5),
              filled: true,
              fillColor: SLColors.surface2,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 11, vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      const BorderSide(color: SLColors.border, width: 1)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      const BorderSide(color: SLColors.border, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                      color: SLColors.accent, width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                      color: SLColors.error, width: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _occupationPills() {
    const opts = ['Employed', 'Self Employed', 'Student', 'Retired'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Occupation type',
            style: TextStyle(
                color: SLColors.textSec,
                fontSize: 12.5,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: opts.map((opt) {
            final sel = _occupation == opt;
            return GestureDetector(
              onTap: () => setState(() => _occupation = opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? SLColors.accent.withOpacity(0.16)
                      : SLColors.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? SLColors.accent : SLColors.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (sel) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: SLColors.accent,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(opt,
                      style: TextStyle(
                          color: sel
                              ? SLColors.accent
                              : SLColors.textSec,
                          fontSize: 13,
                          fontWeight: sel
                              ? FontWeight.w600
                              : FontWeight.w400)),
                ]),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _cityTierButtons() {
    const tiers = [
      ('Tier 1', 'Metro'),
      ('Tier 2', 'Large city'),
      ('Tier 3', 'Small city'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('City tier',
            style: TextStyle(
                color: SLColors.textSec,
                fontSize: 12.5,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Row(
          children: tiers.map((t) {
            final sel = _cityTier == t.$1;
            final isLast = t.$1 == 'Tier 3';
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _cityTier = t.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: isLast ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: sel
                        ? SLColors.accent.withOpacity(0.14)
                        : SLColors.surface2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: sel ? SLColors.accent : SLColors.border,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Column(children: [
                    Text(t.$1,
                        style: TextStyle(
                            color: sel
                                ? SLColors.accent
                                : SLColors.textPri,
                            fontSize: 13,
                            fontWeight: sel
                                ? FontWeight.w700
                                : FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(t.$2,
                        style: const TextStyle(
                            color: SLColors.textSec, fontSize: 10.5)),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _expenseGrid(List<_Exp> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(children: [
              Expanded(child: _miniField(items[i])),
              const SizedBox(width: 10),
              Expanded(
                  child: i + 1 < items.length
                      ? _miniField(items[i + 1])
                      : const SizedBox()),
            ]),
          ),
      ],
    );
  }

  Widget _miniField(_Exp item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.label,
              style: const TextStyle(
                  color: SLColors.textSec,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextFormField(
            controller: item.ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onSaved: (v) => item.onSaved(v),
            style: const TextStyle(
                color: SLColors.textPri, fontSize: 13),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: const TextStyle(
                  color: SLColors.textHint, fontSize: 13),
              filled: true,
              fillColor: SLColors.surface2,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 9),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      const BorderSide(color: SLColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide:
                      const BorderSide(color: SLColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                      color: SLColors.accent, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
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
        onPressed: _onSubmit,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded, size: 18),
            SizedBox(width: 8),
            Text('Predict Savings'),
          ],
        ),
      ),
    );
  }
}

// ── Internal model ─────────────────────────────────────────────────────────
class _Exp {
  final TextEditingController ctrl;
  final String label;
  final void Function(String?) onSaved;
  const _Exp(this.ctrl, this.label, this.onSaved);
}
