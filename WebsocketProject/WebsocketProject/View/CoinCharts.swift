//
//  OneMinCharts.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/15/24.
//

import SwiftUI
import Charts
//Custom Chart
struct CoinCharts: View {
    @ObservedObject var upbitViewModel: UpbitViewModel = UpbitViewModel(market: UpbitManager.shared.marketData[1])
    //코인 종류별 들어오는 가격에 따른 높이 가중치 변화
    @State var chartOffset: Double = 0
    var screenHeightRatio: CGFloat {
        guard let firstPrice = upbitViewModel.firstPrice else { return 0 }
        return 2500 / (firstPrice / 100)
    }
    var screenWidth: CGFloat = 150
    
    var body: some View {
        HStack(alignment: .bottom){
            //Fixed Chart
            ForEach(upbitViewModel.chartData) { data in
                //저장되어있는 데이터로 만든 고정 차트
                chartBar(barWidth: 10, change: data.change * screenHeightRatio, startLine: data.change >= 0 ? data.startLine * screenHeightRatio : (data.startLine + data.change) * screenHeightRatio )
                
            }
            if let presentPrice = upbitViewModel.presentPrice {
                chartBar(barWidth: 10, change: presentPrice.change * screenHeightRatio, startLine: presentPrice.change >= 0 ? presentPrice.startLine * screenHeightRatio : (presentPrice.startLine + presentPrice.change) * screenHeightRatio )
            }
        }
        .offset(y: chartOffset)
        .padding(10)
    }
}

struct chartBar: View {
    
    var barWidth: Double
    var change: Double
    var startLine: Double
    
    var body: some View {
        VStack(spacing: 0){
            //보이는 막대(변화량)
            if change != 0 {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: barWidth, height: change > 0 ? change : -change)
                    .foregroundStyle(change >= 0 ? Color.coinRed : Color.coinBlue)
                    .offset(y: -startLine)
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: barWidth, height: 3)
                    .foregroundStyle(Color.coinRed)
                    .offset(y: -startLine)
            }
        }
    }
}
//
#Preview {
    CoinCharts()
}
