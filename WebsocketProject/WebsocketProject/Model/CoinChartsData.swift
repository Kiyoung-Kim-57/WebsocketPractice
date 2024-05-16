//
//  CoinChartsData.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/15/24.
//

import Foundation

struct CoinChartsData: Identifiable {
    var id: UUID
    //Bar Mark 차트를 위한 데이터(이전 가격 대비 변화량)
    var presentPrice: Double
    var prevPrice: Double
    var change: Double {
        presentPrice - prevPrice
    }
    var prevChange: Double
    var startLine: Double
    var clearHeight: Double {
        if change >= 0{
            return prevPrice
        } else {
            return prevPrice - change
        }
    }
    //Rule or Bar Mark 차트를 위한 데이터(최대치와 최소치 범위 표시)
    var highestPrice: Double
    var lowestPrice: Double
    
    //객체가 생성될 때의 시간
    var chartTime: String
    
    
}

extension CoinChartsData: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
        }
}
