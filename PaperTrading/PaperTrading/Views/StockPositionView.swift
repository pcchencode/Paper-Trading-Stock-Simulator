//
//  StockPositionView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Shows the details about any stock position
struct StockPositionView: View {
    
    @ObservedObject var manager: StocksDataManager
    @State private var frequentRefreshTimer: Timer?
    var portfolioPosition: PositionModel?

    // MARK: - Main rendering function
    var body: some View {
        let position = portfolioPosition ?? manager.positions.first(where: { $0.stock == manager.selectedStock?.symbol })
        let profit = position?.profitLoss(fromLatestPrice: manager.stockDataModel?.prices.last ?? 0.0) ?? "$0.00"
        return VStack {
            if portfolioPosition != nil {
                CreateDashboardPosition(position)
            } else {
                CreateStockDetailsPosition(position, profit: profit).padding()
            }
        }
    }
    
    /// Position view for stock details screen
    private func CreateStockDetailsPosition(_ position: PositionModel?, profit: String) -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Your Positions").font(.system(size: 25))
                    Text(position == nil ? "You don't have any \(manager.selectedStock?.symbol ?? "XYZ") positions" : "See your current position below").opacity(0.60)
                }
                Spacer()
            }
            if position != nil {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Shares").opacity(0.7)
                        Text("\(position!.sharesCount)")
                    }
                    Spacer()
                    VStack(alignment: .center) {
                        Text("P&L").opacity(0.7)
                        Text(profit).bold()
                            .foregroundColor(profit.contains("-") ? AppConfig.negativeColor : AppConfig.tradeButtonColor)
                            .lineLimit(1).minimumScaleFactor(0.5)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Avg Cost").opacity(0.7)
                        Text(position!.purchasePrice.dollarAmount)
                    }
                }.padding().background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))
            }
        }
    }
    
    /// Position view for the dashboard screen
    private func CreateDashboardPosition(_ position: PositionModel?) -> some View {
        let isStockDown = position!.profitLoss(fromLatestPrice: manager.positionsPrices[position!.stock] ?? position!.purchasePrice).contains("-")
        return HStack {
            if position?.stockDetails.companyLogoURL != nil {
                RemoteImage(imageUrl: position!.stockDetails.companyLogoURL)
                    .frame(width: 25, height: 25, alignment: .center).cornerRadius(6)
            } else {
                Image("image_placeholder").resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 25, height: 25, alignment: .center).cornerRadius(6)
            }
            Text(position!.stock).bold()
            Spacer()
            VStack(alignment: .trailing) {
                Text(position!.totalPositionValue(fromLatestPrice: manager.positionsPrices[position!.stock] ?? position!.purchasePrice))
                HStack {
                    Image(systemName: isStockDown ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                    Text(position!.profitLoss(fromLatestPrice: manager.positionsPrices[position!.stock] ?? position!.purchasePrice))
                }
                .font(.system(size: 15))
                .foregroundColor(isStockDown ? AppConfig.negativeColor : AppConfig.tradeButtonColor)
            }
        }
        .padding().background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))
        .onAppear(perform: {
            /// Refresh the last price every 1min
            frequentRefreshTimer?.invalidate()
            frequentRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                manager.fetchLatestPrice(symbol: position!.stock)
            })
        })
    }
}

// MARK: - Render preview UI
struct StockPositionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StockPositionView(manager: StocksDataManager())
                .previewLayout(.sizeThatFits)
            StockPositionView(manager: StocksDataManager(), portfolioPosition: PositionModel(stock: "XYZ", sharesCount: 10, purchasePrice: 100, stockDetails: StockDetailsModel(symbol: "XYZ", companyName: "XYZ", companyLogoURL: AppConfig.stockIconURL.replacingOccurrences(of: "<S>", with: "mcd"))))
                .previewLayout(.sizeThatFits)
        }
    }
}
