//
//  UpbitViewModel.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/13/24.
//

import Foundation
import Combine

class UpbitViewModel: ObservableObject {
    @Published var presentPriceChartData: CoinChartsData?
    @Published var offset: Double?
    @Published var presentPrice: Double?
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
    //이전 시간의 가격
    var prevPrice: Double?
    //처음 입력된 가격
    var firstPrice: Double?
    //가격이 저장됐는지 여부
    var isPrevChecked = false
    var isFirstChecked = false
    //조회할 코인 정보
    var market: MarketModel
    //주기적으로 차트를 업데이트할 타이머
    var timer: Timer?
    //Combine Variables
    var dataPassThrough = PassthroughSubject<TickerModel,Never>()
    var cancellable = Set<AnyCancellable>()
    //Image Array
    let cryingPepes:[ImageCases] = [.crying1,.crying2,.crying3,.crying4]
    let happyPepes:[ImageCases] = [.happy1,.happy2,.happy3]
    let normalPepe:ImageCases = .normal
    @Published var randomCrying: ImageCases = .crying1
    @Published var randomHappy: ImageCases = .happy1
    
    init(market: MarketModel) {
        self.market = market
        //객체가 생성될 때 웹소켓에 연결 후 메시지 전송
//        UpbitManager.shared.connect()
//        UpbitManager.shared.sendMessage(market.code)
//        UpbitManager.shared.receiveMessage(subject: self.dataPassThrough)
        
       
        //웹소켓으로 받은 데이터를 컴바인으로 처리
        dataPassThrough
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ticker in
                guard let self = self else { return }
                
                if !isPrevChecked {
                    self.prevPrice = ticker.tradePrice
                }
                isPrevChecked = true
                
                if !isFirstChecked {
                    self.firstPrice = ticker.tradePrice
                }
                isFirstChecked = true
                
                self.presentPrice = ticker.tradePrice
                
                self.presentPriceChartData = CoinChartsData(id: UUID(),
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
            
            guard let self = self, let price = presentPriceChartData else  { return }
            
            self.isPrevChecked = false
            if self.chartData.count > 13 {
                self.chartData = Array(self.chartData.dropFirst())
            }
            self.chartData.append(price)
            self.offset = chartData[chartData.count - 1].startLine
            //웹소켓에서 데이터 변화가 없어 presentPrice에 변화가 없을 때 생기는 오류 해결
            self.presentPriceChartData = CoinChartsData(id: UUID(),
                                               presentPrice: 0,
                                               prevPrice: 0,
                                               prevChange: chartData[chartData.count - 1].change,
                                               startLine: chartData[chartData.count - 1].startLine + chartData[chartData.count - 1].change,
                                               highestPrice: 0,
                                               lowestPrice: 0,
                                               chartTime: chartData[chartData.count - 1].chartTime)
            self.randomHappy = happyPepes.randomElement()!
            self.randomCrying = cryingPepes.randomElement()!
        })
        
    }
    
    deinit {
        UpbitManager.shared.disconnect()
        timer?.invalidate()
    }
}



