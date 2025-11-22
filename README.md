# Forecasting Service API (ARIMA + FastAPI)

This project was developed for the NASA Space Apps Challenge 2025, created by the Swift Rockets team as part of the NaviSense solution — a mobile platform designed to support Brazilian coastal fishing communities with clear, accessible long-term marine and weather forecasts.

- NASA Space Apps project page: https://www.spaceappschallenge.org/2025/find-a-team/swift-rockets/?tab=project

- Figma prototype: https://www.figma.com/design/b97n80HKuxxC9TWEAb9Ekc/Swift-Rockets?node-id=0-1&amp%3Bt=zXStgmVGxgJIq7vc-1

---

## Overview

This repository contains the forecasting backend used in NaviSense — a **FastAPI** service that generates long-term environmental predictions using a Python-based **ARIMA time-series model**.

Although originally developed for the NaviSense mobile application, the API is modular and can be integrated into any system that requires:

- Long-term weather or climate forecasts
- Environmental data predictions
- Geolocation-based forecasting
- Time-series analysis via a simple REST endpoint

---

## What This API Does

The client (iOS app, web app, or any REST consumer) sends:

* **Latitude**
* **Longitude**
* **A climate parameter** (e.g., temperature, humidity, etc.)
* **A target future date**

Using historical environmental data, the API runs a time-series forecasting model that detects temporal patterns, trends, and dependencies to generate a prediction for the requested date.

The response includes:

* **The forecasted value**
* **The ARIMA model order** selected during fitting
* **A statistical score (AIC)** indicating model quality

It gathers data from:

- [NASA POWER](https://power.larc.nasa.gov/docs/services/api/)
- [Meteomatics](https://www.meteomatics.com/en/meteomatics-and-nasa-space-apps-challenge/)
- [Marine Weather API](https://open-meteo.com/en/docs/marine-weather-api?utm_source=chatgpt.com)

The backend transforms raw climate data into insights using ARIMA forecasting.

---

## API Endpoint

### **POST /forecast**

### **Request**

```json
{
  "lat": -8.12,
  "lon": -34.92,
  "parameter": "RH2M",
  "forecast_date": "20250501"
}
```

### **Response**

```json
{
  "predicted_value": 76.80,
  "arima_order": [2, 0, 2],
  "aic": 41353.14
}
```
---

## Installation & Local Setup

### **1. Clone the repository**

```bash
git clone https://github.com/LayzaCarneiro/ARIMA_Prediction
cd ARIMA_Prediction/arima
```

### **2. Create and activate a virtual environment**

#### macOS/Linux

```bash
python3 -m venv venv
source venv/bin/activate
```

#### Windows

```bash
python -m venv venv
venv\Scripts\activate
```

### **3. Install dependencies**

```bash
pip install -r requirements.txt
```

### **4. Run the FastAPI server**

```bash
uvicorn api_arima:app --reload --host 0.0.0.0 --port 8000
```

### **5. Test the API (optional)**

```bash
curl -X POST "http://localhost:8000/forecast" \
     -H "Content-Type: application/json" \
     -d '{
           "lat": -8.12,
           "lon": -34.92,
           "parameter": "RH2M",
           "forecast_date": "20250501"
         }'
```

---

## Architecture Overview

A view of how the forecasting pipeline works inside the NaviSense ecosystem:

```
               iOS App (Swift)
                      │
                      ▼
          FastAPI Backend — /forecast
                      │
                      ▼
    NASA POWER API — Historical Climate Data
                      │
                      ▼
       ARIMA Time-Series Forecasting Engine
                      │
                      ▼
         Predicted Value Returned to Client
```
---

## 💥 Contributors — Swift Rockets (NASA Space Apps 2025)

| Name                   | Role                                                      | Links                       |
| ---------------------- | --------------------------------------------------------- | --------------------------- |
| **Layza Carneiro**     | iOS Development • Backend Integration • ARIMA Forecasting | [GitHub](https://github.com/LayzaCarneiro) • [LinkedIn](https://www.linkedin.com/in/layzacarneiro/) |
| **João Roberto**       | iOS Development • Mobile Application                      | [GitHub](https://github.com/joaorbrto) • [LinkedIn](https://www.linkedin.com/in/joaorbrto/) |
| **Izadora Montenegro** | iOS Development • Backend Integration • ARIMA Forecasting | [GitHub](https://github.com/izamontenegro) • [LinkedIn](https://www.linkedin.com/in/izadoramontenegro/) |
| **Yago Souza**         | iOS Development • Mobile Application                      | [GitHub](https://github.com/Nhagss) • [LinkedIn](https://www.linkedin.com/in/yago-souza-ramos-621670211/) |
| **Marcelle Queiroz**   | UX/UI Design                                              | [GitHub](https://github.com/maarcq) • [LinkedIn](https://www.linkedin.com/in/marcellerq/) |
| **Clara Alexandre**    | UX/UI Design                                              | [GitHub](https://github.com/claraolvrx) • [LinkedIn](https://www.linkedin.com/in/mclara-de-oliveira/) |

---
