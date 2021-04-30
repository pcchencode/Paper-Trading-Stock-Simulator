//
//  TradeContentView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Main view to buy/sell a stock
struct TradeContentView: View {
    
    @ObservedObject var manager: StocksDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var sharesCount: Int = 1
    @State private var didPurchase: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        let stock = manager.selectedStock?.symbol ?? "XYZ"
        let lastPrice = manager.stockDataModel?.prices.last ?? 0.0
        return VStack {
            Spacer()
            ZStack {
                if didPurchase {
                    confirmationView
                } else {
                    VStack(spacing: 0) {
                        Text("\(sharesCount)").font(.system(size: 40)).bold()
                        Text("How many shares of \(stock) would you like?").foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)).frame(width: UIScreen.main.bounds.width-60, height: 1).padding([.leading, .trailing]).padding()
                        Text("Your total cost will be").padding(.top, 10)
                        Text(Double(Double(sharesCount) * lastPrice).dollarAmount).font(.system(size: 35)).bold()
                    }.lineLimit(1).minimumScaleFactor(0.5)
                    if Double(Double(sharesCount) * lastPrice) > manager.availableTradingBalance {
                        VStack(spacing: 5) {
                            Spacer()
                            Text("Available: \(manager.availableTradingBalance.dollarAmount)")
                                .font(.system(size: 15)).foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                            HStack {
                                Image(systemName: "info.circle.fill")
                                Text("You don't have enough funds")
                            }.foregroundColor(.red).font(.system(size: 15)).padding(.bottom, 8)
                        }
                    }
                }
            }.frame(height: UIScreen.main.bounds.height/2.75)
            Spacer()
            ZStack {
                LinearGradient(gradient: Gradient(colors: [AppConfig.darkBackground]), startPoint: .top, endPoint: .bottom)
                    .mask(RoundedCorner(radius: 45, corners: [.topLeft, .topRight]))
                    .shadow(color: Color(#colorLiteral(red: 0.8827491403, green: 0.9036039114, blue: 0.9225834608, alpha: 1)), radius: 10, x: 0, y: -10)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    CustomNumberInputView(amount: $sharesCount)
                    Spacer()
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        manager.buyShares(amount: sharesCount)
                        didPurchase = true
                    }, label: {
                        Text("Place Order").font(.system(size: 20)).fontWeight(.medium)
                            .padding().padding([.leading, .trailing], 35).foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 40).foregroundColor(AppConfig.tradeButtonColor))
                    }).disabled(!isTransactionValid).opacity(isTransactionValid ? 1 : 0.5)
                }.padding(20)
            }
        }
    }
    
    /// Determine if the transaction details are filled out
    private var isTransactionValid: Bool {
        let lastPrice = manager.stockDataModel?.prices.last ?? 0.0
        if lastPrice == 0.0 { return false }
        return sharesCount > 0 && Double(Double(sharesCount) * lastPrice) < manager.availableTradingBalance
    }
    
    /// Did purchase confirmation view
    private var confirmationView: some View {
        DispatchQueue.main.async { self.sharesCount = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.presentationMode.wrappedValue.dismiss()
        }
        return VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 60))
            Text("Order Placed").font(.title2).foregroundColor(AppConfig.darkBackground)
        }.foregroundColor(AppConfig.tradeButtonColor)
    }
}

// MARK: - Render preview UI
struct TradeContentView_Previews: PreviewProvider {
    static var previews: some View {
        TradeContentView(manager: StocksDataManager())
    }
}
