//
//  AppConfig.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI
import Foundation

/// Basic app configurations
class AppConfig {

    /// Yahoo Finance API
    static let baseURL = "https://query1.finance.yahoo.com/v8/finance/chart/<S>?interval=<T>&range=<R>"
    static let searchURL = "https://query2.finance.yahoo.com/v1/finance/search?q=<Q>&lang=en-US&region=US&newsCount=0"
    static let stockIconURL = "https://s3.polygon.io/logos/<S>/logo.png"
    
    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
    /// Test Interstitial ID: ca-app-pub-3940256099942544/4411468910
    static let adMobAdID: String = "ca-app-pub-3940256099942544/4411468910"
    
    /// Starting paper trading balance
    static let startingBalance: Double = 100000
    
    /// Default stocks for the watchlist
    static let defaultWatchlist: [StockDetailsModel] = [
        StockDetailsModel(symbol: "MCD", companyName: "McDonald's Corporation", companyLogoURL: stockIconURL.replacingOccurrences(of: "<S>", with: "mcd")),
        StockDetailsModel(symbol: "C", companyName: "Citigroup Inc.", companyLogoURL: stockIconURL.replacingOccurrences(of: "<S>", with: "c")),
        StockDetailsModel(symbol: "AMZN", companyName: "Amazon.com, Inc.", companyLogoURL: stockIconURL.replacingOccurrences(of: "<S>", with: "amzn")),
        StockDetailsModel(symbol: "NKE", companyName: "NIKE, Inc.", companyLogoURL: stockIconURL.replacingOccurrences(of: "<S>", with: "nke"))
    ]
    
    // MARK: - UI Configurations
    static let positiveColor = Color(#colorLiteral(red: 0.2656598465, green: 0.8650855179, blue: 0.2666666806, alpha: 1))
    static let negativeColor = Color(#colorLiteral(red: 1, green: 0.2310302541, blue: 0.1019607857, alpha: 1))
    static let darkBackground = Color(#colorLiteral(red: 0.05098039216, green: 0.07450980392, blue: 0.1490196078, alpha: 1))
    static let grayBackground = Color(#colorLiteral(red: 0.9521597028, green: 0.9521597028, blue: 0.9521597028, alpha: 1))
    static let tradeButtonColor = Color(#colorLiteral(red: 0.1503154363, green: 0.7585714334, blue: 0.2666666806, alpha: 1))
}
