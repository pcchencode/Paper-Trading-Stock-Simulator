//
//  AppFeaturesView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

// MARK: - App features configuration
struct AppFeature {
    var title: String
    var subtitle: String
    var icon: String
}

var features: [AppFeature] = [
    AppFeature(title: "Paper Trading", subtitle: "Learn to trade stocks with a demo account. Without real money", icon: "newspaper"),
    AppFeature(title: "One Minute Update", subtitle: "Stock prices updates each minute. Not real-time", icon: "timer"),
    AppFeature(title: "Watchlist", subtitle: "Add your favorite stocks to the watchlist.", icon: "list.star"),
    AppFeature(title: "Market Orders", subtitle: "Your order is executed instantly on the device.", icon: "bolt.fill"),
    AppFeature(title: "Sell All", subtitle: "Sell all your shares for a given stock with one tap. You can't sell a specific amount, only all of them", icon: "dollarsign.circle")
]

/// Main screen to show app features
struct AppFeaturesView: View {

    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                Text("What's New").font(.largeTitle).bold().padding(30).padding(.top, 50)
                VStack(alignment: .leading, spacing: 25) {
                    ForEach(0..<features.count, id: \.self, content: { itemIndex in
                        createItem(feature: features[itemIndex])
                    })
                }.padding([.leading, .trailing], 50)
                Spacer(minLength: 120)
            })
            VStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20).foregroundColor(AppConfig.darkBackground)
                        Text("Continue").font(.system(size: 21)).bold().foregroundColor(.white)
                    }
                }).frame(height: 60).padding().background(Color.white)
            }
        }
    }
    
    /// Create a feature/item line
    private func createItem(feature: AppFeature) -> some View {
        HStack(spacing: 20) {
            Image(systemName: feature.icon).font(.system(size: 40)).foregroundColor(AppConfig.darkBackground).frame(width: 50)
            VStack(alignment: .leading) {
                Text(feature.title).font(.system(size: 25)).bold()
                Text(feature.subtitle).font(.system(size: 15))
            }
        }
    }
}

// MARK: - Render preview UI
struct AppFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        AppFeaturesView()
    }
}
