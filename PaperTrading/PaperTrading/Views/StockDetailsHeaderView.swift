//
//  StockDetailsHeaderView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Header height for the stock details and dashboard view
let headerHeight = UIScreen.main.bounds.height / 3.2

/// Header view for the stock details screen
struct StockDetailsHeaderView: View {
    
    @ObservedObject var manager: StocksDataManager
    @Environment(\.presentationMode) var presentationMode

    // MARK: - Main rendering function
    var body: some View {
        let isStockDown = manager.stockDataModel?.formattedPriceChange.contains("-") ?? false
        return VStack(spacing: 20) {
            ZStack {
                Text(manager.selectedStock?.symbol ?? "XYZ").font(.system(size: 25)).bold().foregroundColor(.white)
                HStack {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        self.manager.selectedStock = nil
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.backward").padding().foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))))
                    }).padding(.leading)
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        if let stock = manager.selectedStock {
                            manager.addRemoveStockToWatchlist(add: !isWatchlisted, stock: stock)
                        }
                    }, label: {
                        Image(systemName: "star\(isWatchlisted ? ".fill" : "")").padding().foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))))
                    }).padding(.trailing)
                }
            }

            ZStack {
                if manager.isFetchingData {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    VStack {
                        if manager.selectedStock?.companyLogoURL != nil {
                            RemoteImage(imageUrl: manager.selectedStock!.companyLogoURL)
                                .frame(width: 60, height: 60).cornerRadius(30)
                        } else {
                            Image("image_placeholder").resizable().aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60).cornerRadius(30)
                        }
                        Text(manager.stockDataModel?.formattedLastPrice ?? "$ - -")
                            .font(.system(size: 45)).bold()
                        HStack {
                            Image(systemName: isStockDown ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                            Text(manager.stockDataModel?.formattedPriceChange ?? "- -")
                        }
                        .font(.system(size: 15))
                        .foregroundColor(isStockDown ? AppConfig.negativeColor : AppConfig.positiveColor)
                    }.foregroundColor(.white)
                }
            }.frame(height: headerHeight - 80).padding([.leading, .trailing], 20)
        }.frame(height: headerHeight)
    }
    
    /// Check if the stock is in the watchlist
    private var isWatchlisted: Bool {
        if let currentStock = manager.selectedStock {
            return manager.watchlistItems.contains(where: { $0.symbol == currentStock.symbol })
        }
        return false
    }
}

// MARK: - Render preview UI
struct StockDetailsHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailsHeaderView(manager: StocksDataManager())
    }
}
