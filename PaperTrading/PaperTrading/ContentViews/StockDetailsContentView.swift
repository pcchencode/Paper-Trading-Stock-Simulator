//
//  StockDetailsContentView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Stock details screen
struct StockDetailsContentView: View {
    
    @ObservedObject var manager: StocksDataManager
    @State private var showTradeView: Bool = false
    @State private var showSellAllAlert: Bool = false
    @State private var frequentRefreshTimer: Timer?
    @State private var intradayRefreshTimer: Timer?
//    @State private var adMobAds: Interstitial!
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            AppConfig.darkBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                StockDetailsHeaderView(manager: manager)
                BottomContainerView
            }
            TradingButtons
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTradeView, content: {
            TradeContentView(manager: manager).onDisappear(perform: {
//                adMobAds.showInterstitialAds()
            })
        })
        .alert(isPresented: $showSellAllAlert, content: {
            Alert(title: Text("Sell all \(manager.selectedStock!.symbol) shares?"), message: Text("Are you sure you want to sell all your shares of \(manager.selectedStock!.symbol)?"), primaryButton: .default(Text("Sell All"), action: {
                manager.sellAllShares()
//                adMobAds.showInterstitialAds()
            }), secondaryButton: .cancel())
        })
        .onDisappear(perform: {
            intradayRefreshTimer?.invalidate()
            frequentRefreshTimer?.invalidate()
        })
        .onAppear(perform: {
//            adMobAds = Interstitial()
            if let stock = manager.selectedStock?.symbol {
                /// Refresh the last price every 1min
                frequentRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
                    manager.fetchLatestPrice(symbol: stock)
                })
                
                /// Refresh the chart after 5min
                intradayRefreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true, block: { (_) in
                    manager.fetchStockData(symbol: stock)
                })
                
                manager.fetchStockData(symbol: stock)
            }
        })
    }

    /// Bottom gray view that holds the chart and other items
    private var BottomContainerView: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                    .foregroundColor(AppConfig.grayBackground)
                    .edgesIgnoringSafeArea(.bottom)
                VStack(spacing: 0) {
                    TimeIntervalSelectorView(manager: manager)
                    ScrollView(showsIndicators: false, content: {
                        ChartSectionView
                        StockPositionView(manager: manager)
                        Spacer(minLength: 100)
                    })
                }
            }
        }
    }
    
    /// Chart view for the stock
    private var ChartSectionView: some View {
        VStack(spacing: 5) {
            ZStack {
                if manager.isFetchingData {
                    Text("loading chart...")
                } else {
                    ChartView(manager: manager, chartHeight: 120)
                }
            }.frame(height: 200)
            Divider().padding([.leading, .trailing])
        }
    }
    
    /// Buy and Sell buttons
    private var TradingButtons: some View {
        ZStack {
            VStack {
                Spacer()
                Color.white.ignoresSafeArea().frame(height: 82)
            }
            VStack(spacing: 0) {
                Spacer()
                Divider()
                HStack(spacing: 20) {
                    createTradeButton(title: "Buy", action: {
                        showTradeView = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    })
                    createTradeButton(title: "Sell All", action: {
                        showSellAllAlert = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }).disabled(!manager.hasOpenPositions).opacity(!manager.hasOpenPositions ? 0.5 : 1.0)
                }.padding()
            }
        }
    }
    
    /// Helper function to create a buy/sell button
    private func createTradeButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30).foregroundColor(AppConfig.tradeButtonColor)
                Text(title).foregroundColor(.white).bold()
            }
        }).frame(height: 50)
    }
}

// MARK: - Render preview UI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailsContentView(manager: StocksDataManager())
    }
}
