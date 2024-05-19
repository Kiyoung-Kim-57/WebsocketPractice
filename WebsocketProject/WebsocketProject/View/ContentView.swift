//
//  ContentView.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/7/24.
//

import SwiftUI

struct ContentView: View {
    //market data - bitcoin in korea
//    @StateObject var upbitViewModel: UpbitViewModel = UpbitViewModel(market: UpbitManager.shared.marketData[0])
    @ObservedObject var marketList: MarketList = MarketList()
    
    var body: some View {
        NavigationStack {
                ScrollView{
                    ForEach(marketList.marketList, id: \.code) { data in
                        
                        NavigationLink {
                            CoinCharts(upbitViewModel: UpbitViewModel(market: data))
                            
                            .onAppear{
                                UpbitManager.shared.connect()
                                UpbitManager.shared.sendMessage(data.code)
                            }
                            .onDisappear{
                                UpbitManager.shared.disconnect()
                            }
                        } label: {
                            Text("\(data.code), \(data.korName)")
                        }
                        
                    }
                }
            
        }
        .onAppear{
            marketList.loadMarketList()
        }
    }
}

#Preview {
    ContentView()
}
