class BudgetInput {
  // Profile
  double? income;
  int? age;
  int? dependents;

  // Fixed Expenses
  double? rent;
  double? loanRepayment;
  double? insurance;

  // Variable Expenses
  double? groceries;
  double? transport;
  double? eatingOut;
  double? entertainment;
  double? utilities;
  double? healthcare;
  double? education;
  double? miscellaneous;

  // Savings
  double? desiredSavingsPercentage;
  double? desiredSavings;
  double? disposableIncome;

  // Occupation one-hot flags
  bool occupationRetired      = false;
  bool occupationSelfEmployed = false;
  bool occupationStudent      = false;

  // City Tier one-hot flags (both false = Tier 1)
  bool cityTier2 = false;
  bool cityTier3 = false;

  // ── Computed labels ────────────────────────────────────────────────────────
  bool get hasData => income != null;

  String get occupationLabel {
    if (occupationRetired)      return 'Retired';
    if (occupationSelfEmployed) return 'Self Employed';
    if (occupationStudent)      return 'Student';
    return 'Employed';
  }

  String get cityTierLabel {
    if (cityTier2) return 'Tier 2';
    if (cityTier3) return 'Tier 3';
    return 'Tier 1';
  }

  // ── Deep copy (used by RootNavigator) ─────────────────────────────────────
  void copyFrom(BudgetInput o) {
    income                   = o.income;
    age                      = o.age;
    dependents               = o.dependents;
    rent                     = o.rent;
    loanRepayment            = o.loanRepayment;
    insurance                = o.insurance;
    groceries                = o.groceries;
    transport                = o.transport;
    eatingOut                = o.eatingOut;
    entertainment            = o.entertainment;
    utilities                = o.utilities;
    healthcare               = o.healthcare;
    education                = o.education;
    miscellaneous            = o.miscellaneous;
    desiredSavingsPercentage = o.desiredSavingsPercentage;
    desiredSavings           = o.desiredSavings;
    disposableIncome         = o.disposableIncome;
    occupationRetired        = o.occupationRetired;
    occupationSelfEmployed   = o.occupationSelfEmployed;
    occupationStudent        = o.occupationStudent;
    cityTier2                = o.cityTier2;
    cityTier3                = o.cityTier3;
  }

  // ── Feature map (matches ML model column names exactly) ───────────────────
  Map<String, dynamic> toFeatureMap() => {
    'Income':                     income                   ?? 0.0,
    'Age':                        age                      ?? 0,
    'Dependents':                 dependents               ?? 0,
    'Rent':                       rent                     ?? 0.0,
    'Loan_Repayment':             loanRepayment            ?? 0.0,
    'Insurance':                  insurance                ?? 0.0,
    'Groceries':                  groceries                ?? 0.0,
    'Transport':                  transport                ?? 0.0,
    'Eating_Out':                 eatingOut                ?? 0.0,
    'Entertainment':              entertainment            ?? 0.0,
    'Utilities':                  utilities                ?? 0.0,
    'Healthcare':                 healthcare               ?? 0.0,
    'Education':                  education                ?? 0.0,
    'Miscellaneous':              miscellaneous            ?? 0.0,
    'Desired_Savings_Percentage': desiredSavingsPercentage ?? 0.0,
    'Desired_Savings':            desiredSavings           ?? 0.0,
    'Disposable_Income':          disposableIncome         ?? 0.0,
    'Occupation_retired':         occupationRetired        ? 1 : 0,
    'Occupation_self_employed':   occupationSelfEmployed   ? 1 : 0,
    'Occupation_student':         occupationStudent        ? 1 : 0,
    'City_Tier_tier_2':           cityTier2                ? 1 : 0,
    'City_Tier_tier_3':           cityTier3                ? 1 : 0,
  };

  // ── URL query string for Streamlit pre-fill ───────────────────────────────
  String toQueryString() => toFeatureMap().entries
      .map((e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
      .join('&');
}
