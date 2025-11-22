import requests
import pandas as pd
import numpy as np
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.stattools import adfuller
import warnings
warnings.filterwarnings('ignore')

def predict_nasa_arima(lat, lon, parameter, forecast_date):
    import requests
    import pandas as pd
    import numpy as np
    from statsmodels.tsa.arima.model import ARIMA
    from statsmodels.tsa.stattools import adfuller
    import itertools
    import warnings
    warnings.filterwarnings('ignore')

    # NASA POWER URL
    start = '20000101'
    end = '20250101'
    url = f"https://power.larc.nasa.gov/api/temporal/daily/point?parameters={parameter}&community=SB&longitude={lon}&latitude={lat}&start={start}&end={end}&format=JSON"
    data = requests.get(url).json()

    # Extract time series
    values = data['properties']['parameter'][parameter]
    df = pd.DataFrame(list(values.items()), columns=['date', 'value'])
    df['date'] = pd.to_datetime(df['date'], format='%Y%m%d')
    df = df.sort_values('date')
    ts = df['value'].dropna()
    ts.index = df['date']  # define a time index (e.g., last 5 years, 10 years, 15 years...)

    # parking space 
    result = adfuller(ts)
    d_range = [1] if result[1] > 0.05 else [0]

    # ARIMA search
    p = range(0, 3)
    q = range(0, 3)
    best_aic = np.inf
    best_order = None
    best_model = None

    for order in itertools.product(p, d_range, q):
        try:
            model = ARIMA(ts, order=order)
            results = model.fit()
            if results.aic < best_aic:
                best_aic = results.aic
                best_order = order
                best_model = results
        except:
            continue

    # Prediction
    last_date = ts.index[-1]
    forecast_date_dt = pd.to_datetime(forecast_date)
    forecast_days = (forecast_date_dt - last_date).days
    if forecast_days <= 0:
        raise ValueError("Forecast date prior to the latest available data")

    forecast = best_model.forecast(steps=forecast_days)
    predicted_value = forecast.iloc[-1]

    return predicted_value, best_order, best_aic


# =======================
# Exemplo de uso
# =======================
lat = -3.7
lon = -38.5
parameter = 'RH2M'
forecast_date = '2025-05-01'

value, order, aic = predict_nasa_arima(lat, lon, parameter, forecast_date)
print(f"Forecast for {forecast_date}: {value:.2f} ({parameter})")
print(f"Best ARIMA order: {order} with AIC {aic:.2f}")
