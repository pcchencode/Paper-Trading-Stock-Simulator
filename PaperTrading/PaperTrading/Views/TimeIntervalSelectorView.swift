//
//  TimeIntervalSelectorView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Select the time period for stock chart
struct TimeIntervalSelectorView: View {
    
    @ObservedObject var manager: StocksDataManager

    // MARK: - Main rendering function
    var body: some View {
        HStack {
            ForEach(StockTimeInterval.allCases, content: { item in
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    manager.timeInterval = item
                    if let stock = manager.selectedStock?.symbol {
                        manager.fetchStockData(symbol: stock)
                    }
                }, label: {
                    Text(item.rawValue).bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(manager.timeInterval == item ? .white : .gray)
                        .background(RoundedRectangle(cornerRadius: 12).foregroundColor(manager.timeInterval == item ? .black : .white).padding(5))
                })
            })
        }
        .frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 15))
        .padding([.leading, .trailing, .top]).padding(.bottom, 10).foregroundColor(.white)
    }
}

// MARK: - Render preview UI
struct TimeIntervalSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        TimeIntervalSelectorView(manager: StocksDataManager())
    }
}
