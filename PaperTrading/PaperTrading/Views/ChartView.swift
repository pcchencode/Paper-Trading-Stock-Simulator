//
//  ChartView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Shows the stock chart
struct ChartView: View {
    
    @ObservedObject var manager: StocksDataManager
    private let chartWidth: CGFloat = UIScreen.main.bounds.width
    var chartHeight: CGFloat = 160
    
    // MARK: - Main rendering function
    var body: some View {
        let chartPoints = manager.timeInterval == .intraday ? 78 : data.count - 1
        let highLowPoint = CGPoint(x: chartWidth / CGFloat(chartPoints), y: chartHeight / CGFloat(data.max()! - data.min()!))
        return ZStack {
            /// Use this as a closed path for the background gradient for the chart
            Path.chart(withPoints: data, highLowPoint: highLowPoint, closePath: true)
                .fill(LinearGradient(gradient: Gradient(colors: [AppConfig.grayBackground.opacity(0.1), mainColor.opacity(0.75)]), startPoint: .top, endPoint: .bottom))
            
            /// Use this as the main chart line
            Path.chart(withPoints: data, highLowPoint: highLowPoint, closePath: false)
                .stroke(mainColor, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
        .rotationEffect(.degrees(180), anchor: .center)
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        .frame(width: chartWidth, height: chartHeight)
    }
    
    /// Chart data
    private var data: [Double] {
        manager.stockDataModel?.prices ?? [1.0, 1.0, 1.0, 1.0]
    }
    
    /// Chart color
    private var mainColor: Color {
        let isStockDown = manager.stockDataModel?.formattedPriceChange.contains("-") ?? false
        return isStockDown ? AppConfig.negativeColor : AppConfig.positiveColor
    }
}

// MARK: - Render preview UI
struct ChartView_Preview: PreviewProvider {
    static var previews: some View {
        ChartView(manager: StocksDataManager())
    }
}
