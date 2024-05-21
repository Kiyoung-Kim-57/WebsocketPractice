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
    var barWidth: Double = 15
//    var geometryHeight: Double
    //numberFormmater
    var numberFormatter: NumberFormatter {
        let format = NumberFormatter()
        format.numberStyle = .decimal
        return format
    }
    
    var body: some View {
        ZStack {
            //background
            Color.white
                .ignoresSafeArea()
            Group {
                if let presentPrice = upbitViewModel.presentPriceChartData {
                    if presentPrice.change > 0 {
                        //Up
                        VStack{
                            Spacer()
                            switch upbitViewModel.randomHappy {
                            case .happy1:
                                Image("pepeHappy1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            case .happy2:
                                Image("pepeHappy2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            case .happy3:
                                Image("pepeHappy3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            default:
                                Image("pepeNormal")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            }
                        }
                        .ignoresSafeArea()
                        //Color background
                        Color.coinRed.opacity(0.15)
                            .ignoresSafeArea()
                    } else if presentPrice.change < 0 {
                        //Down
                        VStack{
                            Spacer()
                            switch upbitViewModel.randomCrying {
                            case .crying1:
                                Image("pepeCrying1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            case .crying2:
                                Image("pepeCrying2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            case .crying3:
                                Image("pepeCrying3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            case .crying4:
                                Image("pepeCrying4")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            default:
                                Image("pepeNormal")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .opacity(0.5)
                            }
                        }
                        .ignoresSafeArea()
                        //Color background
                        Color.coinBlue.opacity(0.15)
                            .ignoresSafeArea()
                    } else {
                        VStack{
                            Spacer()
                            Image("pepeNormal")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .opacity(0.5)
                        }
                        .ignoresSafeArea()
                    }
                }
            }
            
            HStack(alignment: .bottom){
                //Fixed Chart
                ForEach(upbitViewModel.chartData) { data in
                    //저장되어있는 데이터로 만든 고정 차트
                    chartBar(barWidth: barWidth, change: data.change * screenHeightRatio, startLine: data.change >= 0 ? data.startLine * screenHeightRatio : (data.startLine + data.change) * screenHeightRatio )
                    
                }
                if let presentPrice = upbitViewModel.presentPriceChartData {
                    
                        chartBar(barWidth: barWidth, change: presentPrice.change * screenHeightRatio, startLine: presentPrice.change >= 0 ? presentPrice.startLine * screenHeightRatio : (presentPrice.startLine + presentPrice.change) * screenHeightRatio )
                }
            }
            .onAppear{
                UpbitManager.shared.connect()
                UpbitManager.shared.receiveMessage(subject: upbitViewModel.dataPassThrough)
                UpbitManager.shared.sendMessage(upbitViewModel.market.code)
            }
            .offset(y: (upbitViewModel.offset ?? 0) * screenHeightRatio / 2)
            .padding(10)
            
            VStack{
                if let presentPrice = upbitViewModel.presentPrice {
                    Text("\(upbitViewModel.market.engName)\n" + (upbitViewModel.market.code.hasPrefix("KRW") ? "₩ " : "$ ") + numberFormatter.string(from: Int(presentPrice) as NSNumber)!)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                        .font(.system(size: 30))
                        .opacity(0.7)
                }
               Spacer()
            }
        
        }
        
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
                    .foregroundStyle(Color.black)
                    .offset(y: -startLine)
            }
        }
    }
}
//
#Preview {
    CoinCharts()
}
