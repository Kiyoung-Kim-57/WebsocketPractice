//
//  ContentView.swift
//  WebSocketProject Watch App
//
//  Created by 김기영 on 5/21/24.
//

import SwiftUI

struct WatchContentView: View {
    var body: some View {
        ZStack{
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
        }
        .padding()
    }
}

#Preview {
    WatchContentView()
}
