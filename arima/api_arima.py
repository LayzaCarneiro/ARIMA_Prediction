from fastapi import FastAPI
from pydantic import BaseModel
from arima import predict_nasa_arima

app = FastAPI()

# Defines the payload that Swift will send
class ForecastRequest(BaseModel):
    lat: float
    lon: float
    parameter: str
    forecast_date: str  # YYYYMMDD

@app.post("/forecast")
def forecast(request: ForecastRequest):
    value, order, aic = predict_nasa_arima(
        request.lat, request.lon, request.parameter, request.forecast_date
    )
    return {
        "predicted_value": value,
        "arima_order": order,
        "aic": aic
    }

# First create venv, then to run locally: uvicorn api_arima:app --reload --host 0.0.0.0 --port 8000
