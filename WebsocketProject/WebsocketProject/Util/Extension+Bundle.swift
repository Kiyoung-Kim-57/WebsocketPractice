//
//  Extension+Bundle.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/8/24.
//

import Foundation

extension Bundle {
    var coinApiKey: String? {
        guard let filePath = Bundle.main.url(forResource: "KeyList", withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: filePath)
            let result = try PropertyListDecoder().decode(ApiCase.self, from: data)
            return result.coinKey
        } catch {
            return nil
        }
    }
    
    var secretKey: String? {
        guard let filePath = Bundle.main.url(forResource: "KeyList", withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: filePath)
            let result = try PropertyListDecoder().decode(ApiCase.self, from: data)
            return result.secretKey
        } catch {
            return nil
        }
    }
    
    struct ApiCase: Codable {
        var coinKey: String
        var secretKey: String
        
        enum CodingKeys: String, CodingKey {
            case coinKey = "UpbitKey"
            case secretKey = "SecretKey"
        }
    }
}
