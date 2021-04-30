//
//  StockDataModel.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import Foundation

// MARK: - StockDataModel
struct StockDataModel {
    let prices: [Double]
    let previousClose: Double
    
    /// Price change
    var priceChange: Double {
        prices.last! - previousClose
    }
    
    var priceChangePercentage: Double {
        (priceChange/previousClose * 100).rounded(toPlaces: 2)
    }
    
    var formattedPriceChange: String {
        priceChange.dollarAmount + " (\(priceChangePercentage)%)"
    }
    
    var formattedLastPrice: String {
        prices.last!.dollarAmount
    }
}

// MARK: - Time Interval for charts
enum StockTimeInterval: String, CaseIterable, Identifiable {
    case intraday = "1D"
    case weekly = "1W"
    case monthly = "1M"
    case yearly = "1Y"
    var id: Int { hashValue }
    
    /// API request interval
    var formattedURL: String {
        switch self {
        case .intraday:
            return AppConfig.baseURL.replacingOccurrences(of: "<T>", with: "5m").replacingOccurrences(of: "<R>", with: "1d")
        case .weekly:
            return AppConfig.baseURL.replacingOccurrences(of: "<T>", with: "15m").replacingOccurrences(of: "<R>", with: "5d")
        case .monthly:
            return AppConfig.baseURL.replacingOccurrences(of: "<T>", with: "1d").replacingOccurrences(of: "<R>", with: "1mo")
        case .yearly:
            return AppConfig.baseURL.replacingOccurrences(of: "<T>", with: "1d").replacingOccurrences(of: "<R>", with: "1y")
        }
    }
    
    /// This will make a request for each 1m data
    var frequentUpdateURL: String {
        AppConfig.baseURL.replacingOccurrences(of: "<T>", with: "1m").replacingOccurrences(of: "<R>", with: "1d")
    }
}
