//
//  ContentView.swift
//  WebSocketProject Watch App
//
//  Created by 김기영 on 5/22/24.
//

import SwiftUI

struct WatchContentView: View {
    @ObservedObject var marketList: MarketList = MarketList()
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    VStack{
                        Text("Coin List")
                            .foregroundStyle(Color.blue)
                            .font(.system(size: 20))
                            .padding(.top, -10)
                            
                        Divider()
                        ScrollView{
                            ForEach(marketList.marketList, id:\.code) { data in
                                NavigationLink {
                                    CoinCharts(upbitViewModel: UpbitViewModel(market: data), geoHeight: geo.size.height * 2, barWidth: geo.size.width / 20)
                                        .onDisappear{
                                            UpbitManager.shared.disconnect()
                                        }
                                } label: {
                                        CoinListCell(market: data)
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
    }
}

//코인 리스트를 담아낼 셀
private struct CoinListCell: View {
    var market: MarketModel
    var body: some View {
        ZStack{
//            RoundedRectangle(cornerRadius: 20)
//                .foregroundStyle(Color.blue.opacity(0.3))
//                .shadow(color:.white.opacity(0.3),radius: 2, x:2, y:2)
                
            HStack{
                Image(systemName: market.code.hasPrefix("KRW") ? "wonsign.circle" : "dollarsign.circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.blue)
                    .frame(maxHeight: .infinity)
//                Spacer()
                Text(" \(market.korName) \n (\(market.engName)) ")
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .font(.system(size: 15))
                    .minimumScaleFactor(0.3)
//                    .padding([.top, .bottom],5)
                Spacer()
            }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
    }
}

#Preview {
    WatchContentView()
}
