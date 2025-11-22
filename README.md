# 🌊 Forecasting Service API (ARIMA + FastAPI)

This project was developed for the NASA Space Apps Challenge 2025 as part of the Swift Rockets team. You can view the official project submission and design prototype here:

- Project page: https://www.spaceappschallenge.org/2025/find-a-team/swift-rockets/?tab=project

- Figma prototype: https://www.figma.com/design/b97n80HKuxxC9TWEAb9Ekc/Swift-Rockets?node-id=0-1&amp%3Bt=zXStgmVGxgJIq7vc-1

---

The backend of this project is a lightweight **FastAPI service** responsible for generating **long-term environmental forecasts** using an **ARIMA time-series model**.
It was originally built for **NaviSense**, a mobile platform created to support Brazilian coastal communities with accessible long-range marine and meteorological predictions.
However, this backend can be integrated into any application that needs long-term climate or environmental forecasting.

---

## What This API Does

The iOS app — or any client — sends:

* **Latitude**
* **Longitude**
* **A climate parameter** (e.g., temperature, humidity, etc.)
* **A target future date**

Using historical environmental data, the API runs a time-series forecasting model that detects temporal patterns, trends, and dependencies to generate a prediction for the requested date.

The response includes:

* **The forecasted value**
* **The ARIMA model order** selected during fitting
* **A statistical score (AIC)** indicating model quality

All forecasting logic is fully encapsulated, and the API provides a simple, mobile-friendly interface for retrieving predictions.

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
