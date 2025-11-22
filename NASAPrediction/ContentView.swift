//
//  ContentView.swift
//  NASAPrediction
//
//  Created by Layza Maria Rodrigues Carneiro on 04/10/25.
//

import SwiftUI

// MARK: - Modelo do dataset diário
struct DailyData {
    let date: Date
    let rh2m: Double // agora é umidade relativa (%)
}

// MARK: - Estrutura do JSON da API
struct PowerResponse: Codable {
    struct Properties: Codable {
        struct Parameter: Codable {
            let RH2M: [String: Double] // parâmetro atualizado
        }
        let parameter: Parameter
    }
    let properties: Properties
}

// MARK: - Função para previsão simples (média dos últimos 30 dias)
func predictNextMonth(dataset: [DailyData]) -> Double {
    let last30Days = dataset.suffix(30)
    guard !last30Days.isEmpty else { return 0 }
    let avg = last30Days.map { $0.rh2m }.reduce(0, +) / Double(last30Days.count)
    return avg
}

// MARK: - Função de previsão usando regressão linear
func linearRegressionPredictNextMonth(dataset: [DailyData]) -> Double {
    let n = dataset.count
    guard n > 1 else { return dataset.last?.rh2m ?? 0 }
    
    let x = Array(0..<n).map { Double($0) }           // dias como números
    let y = dataset.map { $0.rh2m }                   // valores de umidade
    
    let sumX = x.reduce(0, +)
    let sumY = y.reduce(0, +)
    let sumXY = zip(x, y).map(*).reduce(0, +)
    let sumX2 = x.map { $0 * $0 }.reduce(0, +)
    
    let a = (Double(n) * sumXY - sumX * sumY) / (Double(n) * sumX2 - sumX * sumX)
    let b = (sumY - a * sumX) / Double(n)
    
    let nextX = Double(n + 180) // prever 30 dias à frente
    let predicted = a * nextX + b
    return predicted
}

struct ForecastRequest: Codable {
    let lat: Double
    let lon: Double
    let parameter: String
    let forecast_date: String
}

struct ForecastResponse: Codable {
    let predicted_value: Double
    let arima_order: [Int]
    let aic: Double
}

func fetchARIMAPrediction(lat: Double, lon: Double, parameter: String, forecastDate: String, completion: @escaping (ForecastResponse?) -> Void) {
    guard let url = URL(string: "http://localhost:8000/forecast") else { return }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = ForecastRequest(lat: lat, lon: lon, parameter: parameter, forecast_date: forecastDate)
    request.httpBody = try? JSONEncoder().encode(body)

    URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            print("Erro na requisição: \(error?.localizedDescription ?? "desconhecido")")
            completion(nil)
            return
        }
        let response = try? JSONDecoder().decode(ForecastResponse.self, from: data)
        completion(response)
    }.resume()
}


// MARK: - View
struct ContentView: View {
    @State private var dataset: [DailyData] = []
    @State private var statusMessage: String = "Carregando dados..."

    var body: some View {
        VStack {
            Image(systemName: "humidity.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("NASA POWER Daily Humidity (RH2M)")
                .font(.headline)
            
            // Mostra a previsão de 1 mês
            if !dataset.isEmpty {
                Text("Previsão média RH para próximo mês: \(predictNextMonth(dataset: dataset), specifier: "%.2f") %")
                    .font(.subheadline)
                    .padding(.bottom)
                
                Text("Previsão via regressão linear para próximo mês: \(linearRegressionPredictNextMonth(dataset: dataset), specifier: "%.2f") %")
                    .font(.subheadline)
                    .padding(.bottom)
            }

            Text(statusMessage)
                .padding(.bottom)

            List(dataset, id: \.date) { data in
                Text("\(formattedDate(data.date)): \(data.rh2m, specifier: "%.2f") %")
            }
        }
        .padding()
        .onAppear {
            fetchARIMAPrediction(lat: -3.7, lon: -38.5, parameter: "RH2M", forecastDate: "2025-10-10") { response in
                if let resp = response {
                    print("Previsão: \(resp.predicted_value), ordem ARIMA: \(resp.arima_order), AIC: \(resp.aic)")
                }
            }
        }
    }

    // MARK: - Função para formatação de datas
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Função para buscar os dados da API
    func fetchPowerData() {
        let urlString = "https://power.larc.nasa.gov/api/temporal/daily/point?parameters=RH2M&community=SB&longitude=-38.5&latitude=-3.7&start=20241201&end=20250501&format=JSON"
        
        guard let url = URL(string: urlString) else {
            statusMessage = "URL inválida"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    statusMessage = "Erro: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    statusMessage = "Sem dados"
                }
                return
            }

            let parsedData = parsePowerData(jsonData: data)
            DispatchQueue.main.async {
                if parsedData.isEmpty {
                    statusMessage = "Não foi possível decodificar os dados"
                } else {
                    statusMessage = "Dados carregados: \(parsedData.count) registros"
                    dataset = parsedData
                }
            }
        }.resume()
    }

    // MARK: - Função para decodificar JSON em array DailyData
    func parsePowerData(jsonData: Data) -> [DailyData] {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(PowerResponse.self, from: jsonData)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"

            let dataset: [DailyData] = response.properties.parameter.RH2M.compactMap { key, value in
                if let date = formatter.date(from: key) {
                    return DailyData(date: date, rh2m: value)
                }
                return nil
            }.sorted { $0.date < $1.date }

            return dataset
        } catch {
            print("Erro ao decodificar JSON:", error)
            return []
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
