//
//  PositionModel.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import Foundation

// MARK: - Position
struct PositionModel {
    let stock: String
    let sharesCount: Int
    let purchasePrice: Double
    let stockDetails: StockDetailsModel
    
    /// Get P&L based on the latest stock price
    func profitLoss(fromLatestPrice price: Double) -> String {
        let profitLoss = price - purchasePrice
        let percentage = (profitLoss/purchasePrice * 100).rounded(toPlaces: 2)
        let profit = Double((profitLoss * Double(sharesCount))).dollarAmount
        return "\(profit) (\(percentage)%)"
    }
    
    /// Get P&L based on the latest stock price - Double
    func profitLossDouble(fromLatestPrice price: Double) -> Double {
        let profitLoss = price - purchasePrice
        return profitLoss * Double(sharesCount)
    }
    
    /// Total position value
    func totalPositionValue(fromLatestPrice price: Double) -> String {
        (price * Double(sharesCount)).dollarAmount
    }
    
    /// Total position value - Double
    func totalPositionValueDouble(fromLatestPrice price: Double) -> Double {
        price * Double(sharesCount)
    }
    
    /// Dictionary representation
    var dictionary: [String: Any] {
        [
            "stock": stock, "shares": sharesCount, "price": purchasePrice, "details": stockDetails.dictionary
        ]
    }
    
    /// Create a model with a dictionary
    static func create(fromDictionary dictionary: [String: Any]?) -> PositionModel? {
        guard let data = dictionary else { return nil }
        guard let name = data["stock"] as? String, let shares = data["shares"] as? Int,
              let price = data["price"] as? Double, let details = data["details"] as? [String: Any]
        else { return nil }
        guard let detailsModel = StockDetailsModel.create(fromDictionary: details) else { return nil }
        return PositionModel(stock: name, sharesCount: shares, purchasePrice: price, stockDetails: detailsModel)
    }
}
