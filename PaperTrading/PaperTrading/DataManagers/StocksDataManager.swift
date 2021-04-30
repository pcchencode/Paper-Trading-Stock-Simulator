//
//  StocksDataManager.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import Foundation

/// Fetch stocks data manager
class StocksDataManager: ObservableObject {
    
    /// These properties are dynamic and will invoke UI changes
    @Published var isFetchingData: Bool = false
    @Published var timeInterval: StockTimeInterval = .intraday
    @Published var stockDataModel: StockDataModel?                                  // the main stock data model for a selected stock
    @Published var selectedStock: StockDetailsModel?                                // the main stock details for a selected stock
    @Published var positions = [PositionModel]()                                    // a list of all open positions (purchased stocks)
    @Published var watchlistItems = [StockDetailsModel]()                           // a list of all watchlist stocks
    @Published var positionsPrices = [String: Double]()                             // stock name and the last updated price
    @Published var portfolioBalance: Double = AppConfig.startingBalance             // portfolio balance starting with $100,000
    @Published var availableTradingBalance: Double = AppConfig.startingBalance      // available balance. each other should be less than available balance
    @Published var formattedPortfolioValueChange: String = "$ - -"
    @Published var searchResults = [StockDetailsModel]()
    
    /// Default initializer
    init() {
        fetchSavedUserDefaultsData()
        updatePortfolioBalance()
    }
    
    /// Update portfolio balance
    private func updatePortfolioBalance() {
        let savedBalance = UserDefaults.standard.double(forKey: "balance")
        let profitLoss = positions
            .compactMap({ $0.profitLossDouble(fromLatestPrice: positionsPrices[$0.stock] ?? $0.purchasePrice) })
            .reduce(0, +)
        let totalCostBasis = positions
            .compactMap({ $0.totalPositionValueDouble(fromLatestPrice: $0.purchasePrice )})
            .reduce(0, +)
        availableTradingBalance = savedBalance - totalCostBasis
        portfolioBalance = profitLoss + totalCostBasis + availableTradingBalance
        var valueChange = portfolioBalance - AppConfig.startingBalance
        var percentageChange = (portfolioBalance - AppConfig.startingBalance)/AppConfig.startingBalance * 100
        if totalCostBasis == 0.0 {
            valueChange = portfolioBalance - AppConfig.startingBalance
            percentageChange = (portfolioBalance - AppConfig.startingBalance)/AppConfig.startingBalance * 100
        }
        formattedPortfolioValueChange = "\(valueChange.dollarAmount) (\(percentageChange.rounded(toPlaces: 2))%)"
        saveOpenPositions()
    }
    
    /// Save to user defaults all open positions
    private func saveOpenPositions() {
        var positionsData = [String: Any]()
        positions.forEach { (position) in
            positionsData[position.stock] = position.dictionary
        }
        UserDefaults.standard.setValue(positionsData, forKey: "positionsData")
        UserDefaults.standard.synchronize()
    }
    
    /// Fetch saved user defaults data
    private func fetchSavedUserDefaultsData() {
        if UserDefaults.standard.double(forKey: "balance") == 0.0 {
            UserDefaults.standard.setValue(AppConfig.startingBalance, forKey: "balance")
            UserDefaults.standard.synchronize()
        }
        if let savedPositions = UserDefaults.standard.dictionary(forKey: "positionsData") {
            savedPositions.forEach { (_, data) in
                if let model = PositionModel.create(fromDictionary: data as? [String: Any]) {
                    positions.append(model)
                }
            }
        }
        if let savedWatchlist = UserDefaults.standard.dictionary(forKey: "watchlistData") {
            savedWatchlist.forEach { (_, value) in
                if let model = StockDetailsModel.create(fromDictionary: value as? [String: Any]) {
                    watchlistItems.append(model)
                }
            }
        } else { watchlistItems = AppConfig.defaultWatchlist }
    }
    
    /// Check if the user has any positions for this current stock
    var hasOpenPositions: Bool {
        positions.first(where: { $0.stock == selectedStock?.symbol }) != nil
    }
    
    /// Fetch stock data for a given stock symbol
    /// - Parameter symbol: stock/security symbol
    func fetchStockData(symbol: String) {
        let url = timeInterval.formattedURL.replacingOccurrences(of: "<S>", with: symbol)
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, _, _) in
            DispatchQueue.main.async {
                guard let responseData = data else { self.isFetchingData = false; return }
                guard let dictionary = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSDictionary
                else { self.isFetchingData = false; return }
                guard let priceData = dictionary.value(forKeyPath: "chart.result.indicators.quote.close") as? [Any]
                else { self.isFetchingData = false; return }
                var prices = [Double]()
                ((priceData.first as? [Any])?.first as? [Any])?.forEach { (price) in
                    if let double = price as? Double { prices.append(double) }
                }
                let close = (dictionary.value(forKeyPath: "chart.result.meta.chartPreviousClose") as? [Any])?.first as? Double ?? 1.0
                self.stockDataModel = StockDataModel(prices: prices, previousClose: close)
                self.isFetchingData = false
                self.updatePortfolioBalance()
            }
        }.resume()
    }
    
    /// Fetch the latest price for a stock
    /// - Parameter symbol: stock symbol
    func fetchLatestPrice(symbol: String, completion: ((_ model: StockDataModel) -> Void)? = nil) {
        let url = timeInterval.frequentUpdateURL.replacingOccurrences(of: "<S>", with: symbol)
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, _, _) in
            DispatchQueue.main.async {
                guard let responseData = data else { return }
                guard let dictionary = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? NSDictionary
                else { return }
                guard let priceData = dictionary.value(forKeyPath: "chart.result.indicators.quote.close") as? [Any]
                else { return }
                var prices = [Double]()
                ((priceData.first as? [Any])?.first as? [Any])?.forEach { (price) in
                    if let double = price as? Double { prices.append(double) }
                }
                if let lastPrice = prices.last { self.positionsPrices[symbol] = lastPrice }
                if symbol == self.selectedStock?.symbol {
                    let currentClose = self.stockDataModel?.previousClose ?? 1.0
                    var currentPrices = self.stockDataModel?.prices
                    currentPrices = currentPrices?.dropLast()
                    if let lastPrice = prices.last { currentPrices?.append(lastPrice) }
                    if let updatePrices = currentPrices {
                        self.stockDataModel = StockDataModel(prices: updatePrices, previousClose: currentClose)
                    }
                }
                self.updatePortfolioBalance()
                let close = (dictionary.value(forKeyPath: "chart.result.meta.chartPreviousClose") as? [Any])?.first as? Double ?? 1.0
                completion?(StockDataModel(prices: prices, previousClose: close))
            }
        }.resume()
    }
    
    /// Buy shares of the current `selectedStock`
    /// - Parameter amount: amount of shares
    func buyShares(amount: Int) {
        guard let stockDetails = selectedStock else { return }
        guard let stock = selectedStock?.symbol, let lastPrice = stockDataModel?.prices.last else { return }
        let currentSharesCount = positions.first(where: { $0.stock == stock })?.sharesCount ?? 0
        let currentSharesPrices = positions.first(where: { $0.stock == stock })?.purchasePrice ?? 0
        positions.removeAll(where: { $0.stock == stock })
        let updatedCount = currentSharesCount + amount
        let updatedCostBasis = ((currentSharesPrices * Double(currentSharesCount)) + (lastPrice * Double(amount))) / Double(updatedCount)
        positions.append(PositionModel(stock: stock, sharesCount: updatedCount, purchasePrice: updatedCostBasis, stockDetails: stockDetails))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.updatePortfolioBalance() })
    }
    
    /// Sell all shares for the current `selectedStock`
    func sellAllShares() {
        guard let stock = selectedStock?.symbol else { return }
        guard let currentPosition = positions.first(where: { $0.stock == stock }) else { return }
        let currentPL = currentPosition.profitLossDouble(fromLatestPrice: positionsPrices[stock] ?? currentPosition.purchasePrice)
        UserDefaults.standard.setValue(UserDefaults.standard.double(forKey: "balance")+currentPL, forKey: "balance")
        UserDefaults.standard.synchronize()
        positions.removeAll(where: { $0.stock == stock })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.updatePortfolioBalance() })
    }
    
    /// Add/Remove a stock to the watchlist
    /// - Parameters:
    ///   - add: set true when adding and false when removing
    ///   - stock: stock details model
    func addRemoveStockToWatchlist(add: Bool, stock: StockDetailsModel) {
        let currentItems = watchlistItems
        watchlistItems.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            currentItems.forEach { (item) in
                if stock.symbol != item.symbol { self.watchlistItems.append(item) }
            }
            if add { self.watchlistItems.append(stock) }
            
            /// Save to user defaults
            var watchlistData = [String: Any]()
            self.watchlistItems.forEach({ watchlistData[$0.symbol] = $0.dictionary })
            UserDefaults.standard.setValue(watchlistData, forKey: "watchlistData")
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Search for stocks for a given text/query
    /// - Parameter query: text typed by the user
    func searchForStock(withQuery query: String) {
        if query.isEmpty { searchResults.removeAll() }
        let url = AppConfig.searchURL.replacingOccurrences(of: "<Q>", with: query.lowercased())
        guard let requestURL = URL(string: url) else { self.searchResults.removeAll(); return }
        URLSession.shared.dataTask(with: requestURL) { (data, _, _) in
            DispatchQueue.main.async {
                guard let responseData = data else { return }
                guard let dictionary = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any]
                else { return }
                guard let quotes = dictionary["quotes"] as? [[String: Any]] else { return }
                self.searchResults.removeAll()
                quotes.forEach { (stockResult) in
                    if let symbol = stockResult["symbol"] as? String, let name = stockResult["longname"] as? String,
                          let type = stockResult["quoteType"] as? String, type == "EQUITY" {
                        self.searchResults.append(StockDetailsModel(symbol: symbol, companyName: name,
                                                                    companyLogoURL: AppConfig.stockIconURL.replacingOccurrences(of: "<S>", with: symbol.lowercased())))
                    }
                }
            }
        }.resume()
    }
}
