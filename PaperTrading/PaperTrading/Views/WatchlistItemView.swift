//
//  WatchlistItemView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Shows a watchlist item
struct WatchlistItemView: View {
    
    @ObservedObject var manager: StocksDataManager
    @State private var frequentRefreshTimer: Timer?
    @State private var stockModel = StockDataModel(prices: [1.0], previousClose: 1.0)
    @State var stock: StockDetailsModel
    private let tileWidth: CGFloat = 100
    
    // MARK: - Main rendering function
    var body: some View {
        let isStockDown = stockModel.formattedPriceChange.contains("-")
        return VStack(spacing: 5) {
            RemoteImage(imageUrl: stock.companyLogoURL)
                .frame(width: 40, height: 40, alignment: .center).cornerRadius(6)
            Text(stock.symbol).font(.system(size: 20)).bold()
            Spacer()
            VStack(alignment: .center) {
                Text(didFetchData ? stockModel.formattedLastPrice : "- - -").bold()
                Text(didFetchData ? stockModel.formattedPriceChange : "- -")
                    .font(.system(size: 20))
                    .foregroundColor(isStockDown ? AppConfig.negativeColor : AppConfig.tradeButtonColor)
            }.frame(height: 45)
        }
        .lineLimit(1).minimumScaleFactor(0.5)
        .frame(width: tileWidth, height: tileWidth * 1.2)
        .padding().padding([.top, .bottom], 5).background(RoundedRectangle(cornerRadius: 18).foregroundColor(.white))
        .onAppear(perform: {
            /// Refresh the last price every 1min
            frequentRefreshTimer?.invalidate()
            frequentRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                manager.fetchLatestPrice(symbol: stock.symbol) { (model) in
                    self.stockModel = model
                }
            })
        })
    }
    
    /// Check if data was fetched
    private var didFetchData: Bool {
        stockModel.prices.count > 1
    }
}

// MARK: - Render preview UI
struct WatchlistItemView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistItemView(manager: StocksDataManager(), stock: AppConfig.defaultWatchlist.first!)
            .previewLayout(.sizeThatFits)
    }
}
