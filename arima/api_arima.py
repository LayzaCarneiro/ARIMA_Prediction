from fastapi import FastAPI
from pydantic import BaseModel
from arima import predict_nasa_arima  # sua função ARIMA

app = FastAPI()

# Define o payload que Swift vai enviar
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

# Para rodar localmente: uvicorn api_arima:app --reload --host 0.0.0.0 --port 8000
