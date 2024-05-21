//
//  ContentView.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/7/24.
//

import SwiftUI

struct ContentView: View {
    //market data 
    @ObservedObject var marketList: MarketList = MarketList()
    
    var body: some View {
        NavigationStack {
            VStack{
                Text("Coin List")
                    .font(.system(size: 30))
                Divider()
                ScrollView{
                    ForEach(marketList.marketList, id: \.code) { data in

                        NavigationLink {
                            CoinCharts(upbitViewModel: UpbitViewModel(market: data))
                            .onDisappear{
                                UpbitManager.shared.disconnect()
                            }
                        } label: {
                            CoinListCell(market: data)
                                .foregroundStyle(Color.black)
                                .padding(10)
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

private struct CoinListCell: View {
    var market: MarketModel
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .shadow(radius: 5, x:3, y:5)
            HStack{
                Image(systemName: market.code.hasPrefix("KRW") ? "wonsign.circle" : "dollarsign.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(Color.white)
                    .padding(10)
//                Spacer()
                Text(" \(market.korName) \n (\(market.engName)) ")
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 30))
                    .minimumScaleFactor(0.3)
                    .padding([.top, .bottom],10)
                Spacer()
            }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
    }
}

#Preview {
    ContentView()
}
