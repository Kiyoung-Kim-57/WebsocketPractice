//
//  UpbitViewModel.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/13/24.
//

import Foundation
import Combine

class UpbitViewModel: ObservableObject {
    @Published var presentPrice: TickerModel?
    var market: MarketModel
    var cancellable = Set<AnyCancellable>()
    
    init(market: MarketModel) {
        self.market = market
        
        UpbitManager.shared.connect()
        UpbitManager.shared.sendMessage(market.code)
        
        UpbitManager.shared.dataPassThrough
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ticker in
                guard let self = self else { return }
                self.presentPrice = ticker
            }
            .store(in: &cancellable)
        
        
    }
    
    deinit {
        UpbitManager.shared.disconnect()
    }
    
    
}
