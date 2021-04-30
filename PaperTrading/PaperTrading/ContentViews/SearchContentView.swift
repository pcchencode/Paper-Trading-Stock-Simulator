//
//  SearchContentView.swift
//  PaperTrading
//
//  Created by Apps4World on 3/5/21.
//

import SwiftUI

/// Search for a stock
struct SearchContentView: View {
    
    @ObservedObject var manager: StocksDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText: String = ""
    @State var didSelectStock: (_ stock: StockDetailsModel?) -> Void
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            AppConfig.darkBackground.ignoresSafeArea()
            VStack {
                VStack(spacing: 20) {
                    ZStack {
                        Text("Search").font(.system(size: 25)).bold().foregroundColor(.white)
                        HStack {
                            Spacer()
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }, label: {
                                Image(systemName: "xmark").padding().foregroundColor(.white)
                                    .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))))
                            }).padding(.trailing)
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).foregroundColor(AppConfig.grayBackground)
                        TextField("Enter stock symbol", text: $searchText.onChange({ (text) in
                            manager.searchForStock(withQuery: text)
                        })).padding()
                    }.padding([.leading, .trailing])
                    Spacer()
                }.frame(height: 150)
                BottomContainerView
            }
        }
    }
    
    /// Bottom gray view that holds the chart and other items
    private var BottomContainerView: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedCorner(radius: 30, corners: [.topLeft, .topRight])
                    .foregroundColor(.white).edgesIgnoringSafeArea(.bottom)
                ScrollView(showsIndicators: false, content: {
                    Spacer(minLength: 15)
                    if manager.searchResults.count > 0 {
                        Text("Search Results").font(.title2)
                    }
                    LazyVStack(alignment: .leading) {
                        ForEach(0..<manager.searchResults.count, id: \.self, content: { index in
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                didSelectStock(manager.searchResults[index])
                            }, label: {
                                VStack {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(manager.searchResults[index].symbol).font(.title3)
                                            Text(manager.searchResults[index].companyName).foregroundColor(.gray)
                                        }
                                        Spacer()
                                        RemoteImage(imageUrl: manager.searchResults[index].companyLogoURL)
                                            .frame(width: 40, height: 40).cornerRadius(5)
                                    }
                                    Divider()
                                }
                            }).foregroundColor(.black)
                        })
                    }.padding([.leading, .trailing], 20).padding([.top, .bottom], 15)
                }).padding(.top, 5)
            }
        }
    }
}

// MARK: - Render preview UI
struct SearchContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchContentView(manager: StocksDataManager(), didSelectStock: { _ in })
    }
}
