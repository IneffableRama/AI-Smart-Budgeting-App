
# =============================================
# AI-DRIVEN SMART BUDGETING APP — DUAL MODE VERSION
# Flutter (lightweight) + Web (full dashboard)
# =============================================

import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.cluster import KMeans
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

# Optional XGBoost
try:
    from xgboost import XGBRegressor
    xgb_available = True
except:
    xgb_available = False

# =============================================
# CONFIG
# =============================================
st.set_page_config(page_title="AI Smart Budgeting App", layout="wide")

# =============================================
# LOAD DATA
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
            n_estimators=300,
            learning_rate=0.05,
            max_depth=5,
            subsample=0.8,
            colsample_bytree=0.8,
            random_state=42
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
# RECOMMENDATIONS
# =============================================
def generate_recommendations(user_df):
    recs = []
    expense_cols = [
        "Groceries","Transport","Eating_Out",
        "Entertainment","Utilities","Healthcare","Miscellaneous"
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
# LOAD + TRAIN
# =============================================
df = load_data()
results_df, best_model, scaler = train_models(df)

# =============================================
# CLUSTERING
# =============================================
cluster_features = df[["Income","Total_Potential_Savings","Disposable_Income","Groceries","Eating_Out"]]
kmeans = KMeans(n_clusters=3, random_state=42)
df["User_Type"] = kmeans.fit_predict(cluster_features)

# =============================================
# URL PARAMS
# =============================================
params = st.query_params
mode = params.get("mode", "full")   # prediction / full

# =============================================
# INPUT (NO UI — URL ONLY)
# =============================================
def get_user_input():
    user_input = {}
    feature_cols = df.drop(["Total_Potential_Savings","User_Type"], axis=1).columns

    for col in feature_cols:
        value = params.get(col)

        if value is None or value == "":
            user_input[col] = float(df[col].mean())
        else:
            try:
                user_input[col] = float(value)
            except:
                user_input[col] = float(df[col].mean())

    return user_input

# =============================================
# PREDICTION
# =============================================
def run_prediction(user_input):
    user_df = pd.DataFrame([user_input])

    # Ensure all columns exist
    for col in df.drop(["Total_Potential_Savings","User_Type"], axis=1).columns:
        if col not in user_df.columns:
            user_df[col] = df[col].mean()

    user_df = user_df[df.drop(["Total_Potential_Savings","User_Type"], axis=1).columns]

    user_scaled = scaler.transform(user_df)
    prediction = best_model.predict(user_scaled)[0]

    st.success(f"💸 Estimated Monthly Savings: ₹ {prediction:,.2f}")

    score = min(100, (prediction / user_input.get("Income",1)) * 200)
    st.metric("💎 Financial Health Score", f"{score:.1f}/100")

    # 🔥 Only show heavy UI in FULL mode
    if mode != "prediction":
        cats = ["Groceries","Transport","Eating_Out","Entertainment","Utilities","Healthcare","Miscellaneous"]
        vals = [user_input.get(c,0) for c in cats]

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

# =============================================
# APP ENTRY
# =============================================
if mode == "prediction":
    # 🔥 Flutter mode → minimal UI
    if len(params) == 0:
        st.stop()

    run_prediction(get_user_input())

else:
    # 🌐 Web mode → full dashboard
    st.title("💰 AI-Driven Smart Budgeting App")

    user_input = get_user_input()
    run_prediction(user_input)

# =============================================
# FOOTER
# =============================================
if mode != "prediction":
    st.markdown("---")
    st.markdown("🚀 AI Smart Budgeting System | Flutter + Streamlit + ML")
