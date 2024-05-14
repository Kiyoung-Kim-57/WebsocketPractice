//
//  MarketModel.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/13/24.
//

import Foundation

struct MarketModel: Codable, Hashable {
    var id: UUID
    var code: String
    var korName: String
    var engName: String
}
