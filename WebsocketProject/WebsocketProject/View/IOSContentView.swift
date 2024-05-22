//
//  ContentView.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/7/24.
//

import SwiftUI

struct IOSContentView: View {
    @ObservedObject var marketList: MarketList = MarketList()
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                VStack{
                    Text("Coin List")
                        .foregroundStyle(Color.blue)
                        .font(.system(size: 30))
                    Divider()
                    ScrollView{
                        ForEach(marketList.marketList, id: \.code) { data in
                            
                            NavigationLink {
                                CoinCharts(upbitViewModel: UpbitViewModel(market: data), geoHeight: geo.size.height)
                                    .onDisappear{
                                        UpbitManager.shared.disconnect()
                                    }
                            } label: {
                                CoinListCell(market: data)
                                    .foregroundStyle(Color.black)
                                    .padding([.leading, .trailing], 10)
                                    .padding(.top, 10)
                            }
                            
                        }
                    }
                }
            }
            .onAppear{
                marketList.loadMarketList()
            }
        }
    }
}


private struct CoinListCell: View {
    var market: MarketModel
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.blue.opacity(0.3))
                .shadow(radius: 5, x:3, y:5)
            HStack{
                Image(systemName: market.code.hasPrefix("KRW") ? "wonsign.circle" : "dollarsign.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(Color.blue)
                    .padding(10)
//                Spacer()
                Text(" \(market.korName) \n (\(market.engName)) ")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 30))
                    .minimumScaleFactor(0.3)
                    .foregroundStyle(Color.white)
                    .padding([.top, .bottom],10)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
    }
}

#Preview {
    IOSContentView()
}
