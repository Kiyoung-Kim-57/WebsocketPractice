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
    @ObservedObject var upbitViewModel: UpbitViewModel = UpbitViewModel(market: UpbitManager.shared.marketData[0])
    //코인 종류별 들어오는 가격에 따른 높이 가중치 변화
    var chartOffset: Double {
        upbitViewModel.chartData[upbitViewModel.chartData.count - 1].startLine
    }
    //부모뷰의 사이즈에 따라 차트 높이 비율 조절
    var screenHeightRatio: CGFloat {
        guard let firstPrice = upbitViewModel.firstPrice else { return 0 }
        //분자 부분에 원하는 비율 전달
        return 1500 / (firstPrice / 100)
    }
    var barWidth: Double = 10
//    var geometryHeight: Double
    
    var body: some View {
        HStack(alignment: .bottom){
            //Fixed Chart
            ForEach(upbitViewModel.chartData) { data in
                //저장되어있는 데이터로 만든 고정 차트
                chartBar(barWidth: barWidth, change: data.change * screenHeightRatio, startLine: data.change >= 0 ? data.startLine * screenHeightRatio : (data.startLine + data.change) * screenHeightRatio )
                
            }
            if let presentPrice = upbitViewModel.presentPrice {
                chartBar(barWidth: barWidth, change: presentPrice.change * screenHeightRatio, startLine: presentPrice.change >= 0 ? presentPrice.startLine * screenHeightRatio : (presentPrice.startLine + presentPrice.change) * screenHeightRatio )
            }
        }
        .offset(y: chartOffset * screenHeightRatio / 2)
        .padding(10)
    }
}

//차트 막대
struct chartBar: View {
    
    var barWidth: Double
    //변화량 = 막대의 길이
    var change: Double
    //증감에 따른 차트의 시작점
    var startLine: Double
    
    var body: some View {
        VStack(spacing: 0){
            //보이는 막대(변화량)
            if change != 0 {
                RoundedRectangle(cornerRadius: 2)
//                    .frame(width: barWidth, height: change > 0 ? change : -change)
                    .frame(width: barWidth, height: abs(change))
                    .foregroundStyle(change >= 0 ? Color.coinRed : Color.coinBlue)
                    .offset(y: -startLine)
            } else {
                //변화가 없었을 때의 막대
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: barWidth, height: 3)
                    .foregroundStyle(Color.gray)
                    .offset(y: -startLine)
            }
        }
    }
}
//
//#Preview {
//    CoinCharts()
//}
