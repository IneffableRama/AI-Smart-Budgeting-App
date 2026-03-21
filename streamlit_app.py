# =============================================
# AI-DRIVEN SMART BUDGETING APP — ULTIMATE VERSION
# Backend: ML + Clustering + Recommendations
# Frontend: Streamlit + Plotly (Production Ready)
# =============================================

import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.cluster import KMeans
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

try:
    from xgboost import XGBRegressor
    xgb_available = True
except:
    xgb_available = False

# =============================================
# STREAMLIT CONFIG
# =============================================
st.set_page_config(page_title="AI Smart Budgeting App", layout="wide")

st.markdown("""
<style>
body { background-color: #0e1117; }
</style>
""", unsafe_allow_html=True)

# =============================================
# LOAD QUERY PARAMS FROM FLUTTER
# Reads all feature values passed as URL query parameters.
# Example URL: https://your-app.streamlit.app/?Income=50000&Age=28&...
# =============================================
def get_query_param(key, default=0.0, cast=float):
    """Safely read a single query param, falling back to default."""
    params = st.query_params
    val = params.get(key, None)
    if val is None:
        return default
    try:
        return cast(val)
    except (ValueError, TypeError):
        return default

def load_flutter_inputs():
    """
    Returns a dict of all feature values sourced from URL query params.
    If no params are present (direct Streamlit access), all values default to 0.
    """
    return {
        "Income":                    get_query_param("Income",                    0.0),
        "Age":                       get_query_param("Age",                       0,   cast=int),
        "Dependents":                get_query_param("Dependents",                0,   cast=int),
        "Rent":                      get_query_param("Rent",                      0.0),
        "Loan_Repayment":            get_query_param("Loan_Repayment",            0.0),
        "Insurance":                 get_query_param("Insurance",                 0.0),
        "Groceries":                 get_query_param("Groceries",                 0.0),
        "Transport":                 get_query_param("Transport",                 0.0),
        "Eating_Out":                get_query_param("Eating_Out",                0.0),
        "Entertainment":             get_query_param("Entertainment",             0.0),
        "Utilities":                 get_query_param("Utilities",                 0.0),
        "Healthcare":                get_query_param("Healthcare",                0.0),
        "Education":                 get_query_param("Education",                 0.0),
        "Miscellaneous":             get_query_param("Miscellaneous",             0.0),
        "Desired_Savings_Percentage":get_query_param("Desired_Savings_Percentage",0.0),
        "Desired_Savings":           get_query_param("Desired_Savings",           0.0),
        "Disposable_Income":         get_query_param("Disposable_Income",         0.0),
        "Occupation_retired":        get_query_param("Occupation_retired",        0,   cast=int),
        "Occupation_self_employed":  get_query_param("Occupation_self_employed",  0,   cast=int),
        "Occupation_student":        get_query_param("Occupation_student",        0,   cast=int),
        "City_Tier_tier_2":          get_query_param("City_Tier_tier_2",          0,   cast=int),
        "City_Tier_tier_3":          get_query_param("City_Tier_tier_3",          0,   cast=int),
    }

# Load Flutter inputs once per session
flutter_inputs = load_flutter_inputs()
came_from_flutter = flutter_inputs["Income"] > 0  # True when Flutter sent data

# =============================================
# LOAD & PREP DATA
# =============================================
@st.cache_data
def load_data():
    df = pd.read_csv("Expense_data_cleaned.csv")
    savings_cols = [c for c in df.columns if c.startswith("Potential_Savings_")]
    df["Total_Potential_Savings"] = df[savings_cols].sum(axis=1)
    df.drop(columns=savings_cols, inplace=True)
    df = pd.get_dummies(df, drop_first=True)
    return df

# =============================================
# TRAIN MODELS
# =============================================
@st.cache_resource
def train_models(df):
    X = df.drop("Total_Potential_Savings", axis=1)
    y = df["Total_Potential_Savings"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    scaler = StandardScaler()
    X_train_s = scaler.fit_transform(X_train)
    X_test_s = scaler.transform(X_test)

    models = {
        "Linear Regression": LinearRegression(),
        "Random Forest": RandomForestRegressor(n_estimators=200, random_state=42),
        "Gradient Boosting": GradientBoostingRegressor(n_estimators=200, learning_rate=0.05)
    }

    if xgb_available:
        models["XGBoost"] = XGBRegressor(
            n_estimators=300, learning_rate=0.05, max_depth=5,
            subsample=0.8, colsample_bytree=0.8, random_state=42
        )

    results = []
    trained_models = {}

    for name, model in models.items():
        model.fit(X_train_s, y_train)
        preds = model.predict(X_test_s)
        trained_models[name] = model
        results.append({
            "Model": name,
            "MAE": mean_absolute_error(y_test, preds),
            "RMSE": np.sqrt(mean_squared_error(y_test, preds)),
            "R2": r2_score(y_test, preds)
        })

    results_df = pd.DataFrame(results).sort_values("R2", ascending=False)
    best_model = trained_models[results_df.iloc[0]["Model"]]
    return results_df, best_model, scaler

# =============================================
# AI RECOMMENDATIONS
# =============================================
def generate_recommendations(user_df):
    recs = []
    expense_cols = [
        "Groceries", "Transport", "Eating_Out",
        "Entertainment", "Utilities", "Healthcare", "Miscellaneous"
    ]
    avg = user_df[expense_cols].mean().mean()
    for col in expense_cols:
        if col in user_df.columns and user_df[col].values[0] > avg * 1.2:
            save = user_df[col].values[0] * 0.15
            recs.append(f"🔻 Reduce **{col}** by 15% → Save ₹{save:,.0f}")
    if not recs:
        recs.append("✅ Your spending pattern is already balanced")
    return recs

# =============================================
# MAIN APP
# =============================================
st.title("💰 AI-Driven Smart Budgeting App")
st.markdown("End-to-end AI system for savings prediction, insights, and recommendations")

# Show a banner when data arrived from Flutter
if came_from_flutter:
    st.success(
        f"📱 **Inputs received from Flutter app** — "
        f"Income: ₹{flutter_inputs['Income']:,.0f} | "
        f"Age: {flutter_inputs['Age']} | "
        f"Prediction running automatically below ↓",
        icon="✅"
    )

df = load_data()
results_df, best_model, scaler = train_models(df)

# =============================================
# USER SEGMENTATION (CLUSTERING)
# =============================================
cluster_features = df[["Income", "Total_Potential_Savings", "Disposable_Income", "Groceries", "Eating_Out"]]
kmeans = KMeans(n_clusters=3, random_state=42)
df["User_Type"] = kmeans.fit_predict(cluster_features)

# =============================================
# TABS
# =============================================
tab1, tab2, tab3 = st.tabs(["📊 Data Explorer", "🤖 Model Comparison", "🔮 Smart Prediction"])

# ── TAB 1 ──────────────────────────────────────────────────────────────────
with tab1:
    st.subheader("Dataset Overview")
    st.dataframe(df.head())

    col = st.selectbox("Select feature", df.select_dtypes(include=np.number).columns)
    fig = px.histogram(df, x=col, nbins=40, title=f"Distribution of {col}")
    st.plotly_chart(fig, use_container_width=True)

    st.subheader("User Segmentation")
    fig2 = px.scatter(df, x="Income", y="Total_Potential_Savings",
                      color="User_Type", title="Income vs Savings Clusters")
    st.plotly_chart(fig2, use_container_width=True)

# ── TAB 2 ──────────────────────────────────────────────────────────────────
with tab2:
    st.subheader("ML Model Performance")
    st.dataframe(results_df)

    fig = px.bar(results_df, x="Model", y="R2", color="Model", title="R² Score Comparison")
    st.plotly_chart(fig, use_container_width=True)

    fig2 = go.Figure()
    fig2.add_bar(name="MAE", x=results_df["Model"], y=results_df["MAE"])
    fig2.add_bar(name="RMSE", x=results_df["Model"], y=results_df["RMSE"])
    fig2.update_layout(barmode='group', title="Error Metrics")
    st.plotly_chart(fig2, use_container_width=True)

# ── TAB 3 ──────────────────────────────────────────────────────────────────
with tab3:
    st.subheader("Predict & Optimize Savings")

    feature_cols = df.drop(["Total_Potential_Savings", "User_Type"], axis=1).columns

    # Pre-fill number inputs from Flutter params if available; otherwise use dataset mean
    user_input = {}
    for col in feature_cols:
        default_val = float(flutter_inputs.get(col, df[col].mean()))
        user_input[col] = st.number_input(
            col,
            value=default_val,
            key=f"input_{col}"
        )

    # Auto-run prediction when Flutter sent data; otherwise require button click
    run_prediction = came_from_flutter or st.button("Predict Savings")

    if run_prediction:
        user_df = pd.DataFrame([user_input])
        user_scaled = scaler.transform(user_df)
        prediction = best_model.predict(user_scaled)[0]

        st.success(f"💸 Estimated Monthly Savings: ₹ {prediction:,.2f}")

        score = min(100, (prediction / max(user_input.get("Income", 1), 1)) * 200)
        st.metric("💎 Financial Health Score", f"{score:.1f}/100")

        cats = ["Groceries", "Transport", "Eating_Out", "Entertainment",
                "Utilities", "Healthcare", "Miscellaneous"]
        vals = [user_input.get(c, 0) for c in cats]

        radar = go.Figure(go.Scatterpolar(r=vals, theta=cats, fill='toself'))
        radar.update_layout(title="Expense Distribution")
        st.plotly_chart(radar, use_container_width=True)

        st.subheader("🧠 AI Budget Recommendations")
        recs = generate_recommendations(user_df)
        for r in recs:
            st.markdown(r)

        gauge = go.Figure(go.Indicator(
            mode="gauge+number",
            value=prediction,
            title={'text': "Savings Potential"},
            gauge={'axis': {'range': [0, df['Total_Potential_Savings'].max()]}}
        ))
        st.plotly_chart(gauge, use_container_width=True)

        if came_from_flutter:
            st.info("💡 Adjust any value above and click **Predict Savings** to re-run.")

# =============================================
# FOOTER
# =============================================
st.markdown("---")
st.markdown("🚀 Deployed AI Smart Budgeting System | ML + Visualization + Intelligence")
