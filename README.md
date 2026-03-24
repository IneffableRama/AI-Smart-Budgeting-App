# 💰 AI-Smart Budgeting App

**AI-Driven Smart Budgeting App** — A Vellore Institute of Technology Bhopal Final Year Capstone Project

An end-to-end AI system that combines machine learning, data analysis, and interactive visualization to help users predict savings, optimize budgets, and make informed financial decisions.

---

## 📋 Table of Contents

- [What It Does](#what-it-does)
- [Why Use This](#why-use-this)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Technology Stack](#technology-stack)
- [Usage Guide](#usage-guide)
- [Support & Documentation](#support--documentation)
- [Contributing](#contributing)

---

## 🎯 What It Does

The AI-Smart Budgeting App provides a full-stack solution for personal financial management:

- **Savings Prediction**: ML models predict monthly savings potential based on your income and spending patterns
- **Smart Recommendations**: AI-generated budget optimization tips to reduce spending by up to 15% in key categories
- **Cross-Platform Access**: Streamlit web interface + Flutter mobile app with seamless integration

---

## ✨ Why Use This

### Key Benefits

- **Accurate Predictions**: Multiple ML models trained on real expense data deliver high-accuracy savings forecasts
- **Personalized Insights**: AI analyzes your specific spending behavior and suggests targeted cost reduction opportunities
- **Visual Analytics**: Interactive Plotly charts make complex financial data easy to understand
- **User Segmentation**: KMeans clustering identifies your spending profile and offers tailored advice
- **Production-Ready**: Built with scalable frameworks (Streamlit, Flutter) for real-world deployment

### Use Cases

- Budget optimization for personal finances
- Expense tracking and analysis
- Financial goal planning and forecasting
- Understanding spending patterns across demographics

---

## 🚀 Quick Start

### Backend (Streamlit Web App)

**Prerequisites:**
- Python 3.8+
- pip (Python package manager)

**Installation:**

\\\`bash
# Clone the repository
git clone https://github.com/HereticCoder/AI-Smart-Budgeting-App.git
cd AI-Smart-Budgeting-App

# Install dependencies
pip install -r requirements.txt

# Run the Streamlit app
streamlit run ai_smart_budgeting_app_full_stack_streamlit_app.py
\\\`

**Required Dependencies:**
- streamlit — Web framework for the UI
- pandas, numpy — Data manipulation and analysis
- scikit-learn — Machine learning models and preprocessing
- plotly, matplotlib — Data visualization
- xgboost, joblib — Advanced ML models and serialization

### Frontend (Flutter Mobile App)

**Prerequisites:**
- Flutter SDK (>=3.0.0, <4.0.0)
- Android Studio / Xcode (for emulator/device testing)

**Installation:**

\\\`bash
# Navigate to frontend directory
cd frontend

# Install dependencies
flutter pub get

# Run on emulator or connected device
flutter run
\\\`

**Flutter Dependencies:**
- webview_flutter — Embedded web view for Streamlit integration
- url_launcher — Deep linking to Streamlit app with query parameters

---

## 📂 Project Structure

\\\`
AI-Smart-Budgeting-App/
├── README.md                              # This file
├── requirements.txt                       # Python dependencies
├── streamlit_app.py                       # Main Streamlit web application
├── ai_smart_budgeting_app_full_stack_streamlit_app.py  # Alternative version
├── Expense_data_cleaned.csv              # Training dataset (~8.5 MB)
├── frontend/                             # Flutter mobile app
│   ├── pubspec.yaml                      # Flutter dependencies
│   ├── lib/                              # Dart source code
│   ├── android/                          # Android build configuration
│   ├── ios/                              # iOS build configuration
│   └── web/                              # Web build output
└── .idea/                                # IDE configuration
\\\`

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Web Frontend** | Streamlit + Plotly | Interactive dashboards & visualizations |
| **Mobile Frontend** | Flutter (Dart) | Cross-platform mobile app |
| **Backend Logic** | Python + scikit-learn | ML model training & predictions |
| **ML Models** | Linear Regression, Random Forest, Gradient Boosting, XGBoost | Savings prediction algorithms |
| **Data Processing** | Pandas, NumPy | Data cleaning & feature engineering |
| **Clustering** | KMeans | User segmentation analysis |
| **Visualization** | Plotly, Matplotlib | Interactive & static charts |

---

## 📖 Usage Guide

### Via Streamlit Web App

**Smart Prediction** — Make predictions:
   - Enter your financial details (income, expenses, dependents, etc.)
   - Get instant savings estimates and financial health score
   - View expense distribution radar chart
   - Receive AI-powered budget recommendations

### Flutter App Integration

The Flutter app (budget_optimizer) opens a WebView to the Streamlit app and passes user inputs as URL query parameters:

\\\`
https://your-streamlit-app.com/?Income=50000&Age=28&Rent=15000&...
\\\`

The Streamlit app automatically processes these parameters and runs predictions without requiring manual input.

---

## 📊 How It Works

1. **Data Loading**: App loads \`Expense_data_cleaned.csv\` and aggregates potential savings columns
2. **Model Training**: Multiple ML models are trained on 80% of the data using StandardScaler normalization
3. **Prediction**: User inputs are scaled and passed through the best-performing model
4. **Analysis**: 
   - KMeans clustering segments users into 3 spending profiles
   - AI recommendation engine suggests cost reductions for above-average categories
5. **Visualization**: Results displayed via interactive Plotly gauges, radar charts, and bar graphs

---

## ❓ Support & Documentation

- **Flutter Documentation**: [flutter.dev](https://flutter.dev)
- **Streamlit Docs**: [streamlit.io/docs](https://streamlit.io/docs)
- **scikit-learn Guide**: [scikit-learn.org](https://scikit-learn.org)
- **XGBoost Reference**: [xgboost.readthedocs.io](https://xgboost.readthedocs.io)

For issues, feature requests, or questions, please open a [GitHub Issue](https://github.com/HereticCoder/AI-Smart-Budgeting-App/issues).

---

## 🤝 Contributing

We welcome contributions! Whether it's bug fixes, feature enhancements, or documentation improvements:

1. **Fork** the repository
2. **Create** a feature branch: \`git checkout -b feature/YourFeatureName\`
3. **Commit** your changes: \`git commit -m "Add YourFeatureName"\`
4. **Push** to the branch: \`git push origin feature/YourFeatureName\`
5. **Open** a Pull Request with a clear description

### Development Tips

- Test the Streamlit app: \`streamlit run ai_smart_budgeting_app_full_stack_streamlit_app.py\`
- Test the Flutter app: \`flutter run\` from the \`frontend/\` directory
- Ensure dependencies are installed: \`pip install -r requirements.txt\` (Python) and \`flutter pub get\` (Dart)

---

## 📝 License

This project is part of the Vellore Institute of Technology Bhopal Final Year Capstone Program.

---

**Built with ❤️ by the AI-Smart Budgeting Team**  
