//
//  WebsocketProjectApp.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/7/24.
//

import SwiftUI

@main
struct WebsocketProjectApp: App {
    @StateObject var marketList: MarketList = MarketList()
    var body: some Scene {
        WindowGroup {
            #if os(watchOS)
            WatchContentView()
            #else
            IOSContentView(marketList: marketList)
            #endif
        }
    }
}
