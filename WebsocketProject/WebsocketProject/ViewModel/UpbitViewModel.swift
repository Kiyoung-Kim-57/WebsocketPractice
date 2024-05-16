//
//  UpbitViewModel.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/13/24.
//

import Foundation
import Combine

class UpbitViewModel: ObservableObject {
    @Published var presentPrice: CoinChartsData?
    @Published var chartData: [CoinChartsData] = [
        //Bitcoin Test Code
//        .init(id: UUID(), presentPrice: 91300000, prevPrice: 91300000, prevChange: 0, startLine: 0, highestPrice: 12, lowestPrice: 3, chartTime: "11:00"),
//        .init(id: UUID(), presentPrice: 91330000, prevPrice: 91300000, prevChange: 0, startLine: 0, highestPrice: 15, lowestPrice: 8, chartTime: "11:01"),
//        .init(id: UUID(), presentPrice: 91350000, prevPrice: 91330000, prevChange: 30000, startLine: 30000, highestPrice: 13, lowestPrice: 7, chartTime: "11:02"),
//        .init(id: UUID(), presentPrice: 91280000, prevPrice: 91350000, prevChange: 20000, startLine: 50000, highestPrice: 21, lowestPrice: 13, chartTime: "11:03"),
//        .init(id: UUID(), presentPrice: 91310000, prevPrice: 91280000, prevChange: -70000, startLine: -20000, highestPrice: 20, lowestPrice: 3, chartTime: "11:04")
        .init(id: UUID(), presentPrice: 0, prevPrice: 0, prevChange: 0, startLine: 0, highestPrice: 0, lowestPrice: 0, chartTime: "11:00"),
        .init(id: UUID(), presentPrice: 0, prevPrice: 0, prevChange: 0, startLine: 0, highestPrice: 0, lowestPrice: 0, chartTime: "11:00"),
        .init(id: UUID(), presentPrice: 0, prevPrice: 0, prevChange: 0, startLine: 0, highestPrice: 0, lowestPrice: 0, chartTime: "11:00"),
        .init(id: UUID(), presentPrice: 0, prevPrice: 0, prevChange: 0, startLine: 0, highestPrice: 0, lowestPrice: 0, chartTime: "11:00"),
        .init(id: UUID(), presentPrice: 0, prevPrice: 0, prevChange: 0, startLine: 0, highestPrice: 0, lowestPrice: 0, chartTime: "11:00")
        
    ]
    var prevPrice: Double?
    var firstPrice: Double?
    var isPrevChecked = true
    var isFirstChecked = true
    var market: MarketModel
    var timer: Timer?
    var cancellable = Set<AnyCancellable>()
    
    init(market: MarketModel) {
        self.market = market
        //객체가 생성될 때 웹소켓에 연결 후 메시지 전송
        UpbitManager.shared.connect()
        UpbitManager.shared.sendMessage(market.code)
        
        UpbitManager.shared.dataPassThrough
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ticker in
                guard let self = self else { return }
                
                if isPrevChecked {
                    self.prevPrice = ticker.tradePrice
                }
                isPrevChecked = false
                
                if isFirstChecked {
                    self.firstPrice = ticker.tradePrice
                }
                isFirstChecked = false
                
                self.presentPrice = CoinChartsData(id: UUID(),
                                                   presentPrice: ticker.tradePrice,
                                                   prevPrice: prevPrice ?? 0,
                                                   prevChange: chartData[chartData.count - 1].change,
                                                   startLine: chartData[chartData.count - 1].startLine + chartData[chartData.count - 1].change,
                                                   highestPrice: ticker.highPrice,
                                                   lowestPrice: ticker.lowPrice,
                                                   chartTime: ticker.tradeTime)
            }
            .store(in: &cancellable)
        //5초에 한번씩 값 저장
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [weak self] _ in
            guard let self = self, let price = presentPrice else  { return }
            self.isPrevChecked = true
            if self.chartData.count > 19 {
                self.chartData = Array(self.chartData.dropFirst())
            }
            self.chartData.append(price)
            //웹소켓에서 데이터 변화가 없어 presentPrice에 변화가 없을 때 생기는 오류 해결
            self.presentPrice = CoinChartsData(id: UUID(),
                                               presentPrice: 0,
                                               prevPrice: 0,
                                               prevChange: chartData[chartData.count - 1].change,
                                               startLine: chartData[chartData.count - 1].startLine + chartData[chartData.count - 1].change,
                                               highestPrice: 0,
                                               lowestPrice: 0,
                                               chartTime: chartData[chartData.count - 1].chartTime)
        })
        
    }
    
    deinit {
        UpbitManager.shared.disconnect()
        timer?.invalidate()
    }
    
    
}
