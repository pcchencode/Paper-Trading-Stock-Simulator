//
//  DashboardContentView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Main content/app screen
struct DashboardContentView: View {
    
    @ObservedObject private var manager = StocksDataManager()
    @State private var showStockSearchFlow = false
    @State private var showDetails = false
    
    // MARK: - Main rendering function
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: StockDetailsContentView(manager: manager), isActive: $showDetails,
                               label: { EmptyView() }).hidden()
                ZStack {
                    AppConfig.darkBackground.ignoresSafeArea()
                    VStack(spacing: 0) {
                        HeaderView
                        BottomContainerView
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showStockSearchFlow, content: {
                SearchContentView(manager: manager, didSelectStock: { selectedStock in
                    manager.selectedStock = selectedStock
                    manager.searchResults.removeAll()
                    if selectedStock != nil { showDetails = true }
                })
            })
        }
    }
    
    /// Dashboard header view
    private var HeaderView: some View {
        let isStockDown = manager.formattedPortfolioValueChange.contains("-")
        return VStack(spacing: 20) {
            ZStack {
                Text("Dashboard").font(.system(size: 25)).bold().foregroundColor(.white)
                HStack {
                    Spacer()
                    Button(action: {
                        showStockSearchFlow = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }, label: {
                        Image(systemName: "magnifyingglass").padding().foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))))
                    }).padding(.trailing)
                }
            }

            ZStack {
                if manager.isFetchingData {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Portfolio Balance")
                            Text(manager.portfolioBalance.dollarAmount).font(.system(size: 45)).bold()
                            HStack {
                                Image(systemName: isStockDown ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                                Text(manager.formattedPortfolioValueChange)
                            }
                            .font(.system(size: 15))
                            .foregroundColor(isStockDown ? AppConfig.negativeColor : AppConfig.positiveColor)
                            Spacer()
                            HStack {
                                Spacer()
                                Text("All time portfolio Value").opacity(0.4)
                                Spacer()
                            }
                        }.foregroundColor(.white).lineLimit(1).minimumScaleFactor(0.5)
                        Spacer()
                    }
                }
            }.frame(height: headerHeight - 100).padding([.leading, .trailing], 20)
        }.frame(height: headerHeight - 20)
    }
    
    /// Bottom gray view that holds the chart and other items
    private var BottomContainerView: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                    .foregroundColor(AppConfig.grayBackground)
                    .edgesIgnoringSafeArea(.bottom)
                ScrollView(showsIndicators: false, content: {
                    Spacer(minLength: 15)
                    WatchlistView
                    InvestmentsListView
                }).padding(.top, 5)
            }
        }
    }
    
    /// Investments list view
    private var InvestmentsListView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("All Investments").font(.system(size: 25))
                    Text(manager.positions.count > 0 ? "P&L - Since purchase date" : "You don't have any investments yet").opacity(0.60)
                }.padding([.leading, .trailing])
                Spacer()
            }
            VStack {
                ForEach(0..<manager.positions.count, id: \.self, content: { index in
                    Button(action: {
                        manager.selectedStock = manager.positions[index].stockDetails
                        showDetails = true
                    }, label: {
                        StockPositionView(manager: manager, portfolioPosition: manager.positions[index])
                            .padding([.leading, .trailing]).padding([.top, .bottom], 5)
                    }).foregroundColor(AppConfig.darkBackground)
                })
            }
        }
    }
    
    /// Watchlist view
    private var WatchlistView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Watchlist").font(.system(size: 25))
                    Text("Doesn't include your positions").opacity(0.60)
                }.padding([.leading, .trailing])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack(spacing: 18) {
                    ForEach(0..<manager.watchlistItems.count, id: \.self, content: { index in
                        Button(action: {
                            manager.selectedStock = manager.watchlistItems[index]
                            showDetails = true
                        }, label: {
                            WatchlistItemView(manager: manager, stock: manager.watchlistItems[index])
                        }).foregroundColor(AppConfig.darkBackground)
                    })
                }
            }).padding([.leading, .trailing])
        }.padding(.bottom, 30)
    }
}

// MARK: - Render preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView()
    }
}
