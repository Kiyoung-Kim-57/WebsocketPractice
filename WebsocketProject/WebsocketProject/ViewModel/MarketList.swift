//
//  MarketList.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/18/24.
//

import Foundation

class MarketList: ObservableObject {
    @Published var marketList: [MarketModel] = []
    
    func loadMarketList() {
        //마켓코드 리퀘스트 받아서 저장
        UpbitManager.shared.marketCodesRequest {[weak self] result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self?.marketList = success.filter{ $0.code.hasPrefix("KRW") || $0.code.hasPrefix("USDT") }
    //                    .sorted(by: {$0.korName < $1.korName})
                }
            case .failure(let failure):
                print("error occured in\(#function): \(failure.localizedDescription)")
            }
        }
    }
}
