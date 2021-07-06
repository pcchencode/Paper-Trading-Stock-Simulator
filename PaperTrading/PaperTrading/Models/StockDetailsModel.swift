//
//  StockDetailsModel.swift
//  PaperTrading
//
//  Created by Rene B Dena on 3/5/21.
//

import Foundation

// MARK: - Stock details
struct StockDetailsModel {
    let symbol: String
    let companyName: String
    let companyLogoURL: String
    
    /// Dictionary representation
    var dictionary: [String: Any] {
        [
            "symbol": symbol, "name": companyName, "url": companyLogoURL
        ]
    }
    
    /// Create a model with a dictionary
    static func create(fromDictionary dictionary: [String: Any]?) -> StockDetailsModel? {
        guard let data = dictionary else { return nil }
        guard let name = data["name"] as? String, let symbol = data["symbol"] as? String, let url = data["url"] as? String else { return nil }
        return StockDetailsModel(symbol: symbol, companyName: name, companyLogoURL: url)
    }
}
