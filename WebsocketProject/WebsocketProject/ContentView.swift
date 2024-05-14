//
//  ContentView.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/7/24.
//

import SwiftUI

struct ContentView: View {
    //market data - bitcoin in korea
    @StateObject var upbitViewModel: UpbitViewModel = UpbitViewModel(market: UpbitManager.shared.marketData[0])
    
    var body: some View {
        VStack {
            Button {
                UpbitManager.shared.disconnect()
            } label: {
                Text("Disconnect WebSocket")
                    .foregroundStyle(Color.white)
                    .padding(10)
                    .background(content: {
                        RoundedRectangle(cornerRadius: 10)
                    })
            }
            if let price = upbitViewModel.presentPrice {
                Text("₩ \(price.tradePrice)")
            } else {
                Text("No Price Data")
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
