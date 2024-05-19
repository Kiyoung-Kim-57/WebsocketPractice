//
//  MarketModel.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/13/24.
//

import Foundation

struct MarketModel: Codable, Hashable {
    var code: String
    var korName: String
    var engName: String
//    var marketWarning: String
    
    enum CodingKeys: String, CodingKey {
        case code = "market"
        case korName = "korean_name"
        case engName = "english_name"
//        case marketWarning = "market_warning"
    }
}
