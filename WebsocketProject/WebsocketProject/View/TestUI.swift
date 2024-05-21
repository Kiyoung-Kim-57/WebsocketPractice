//
//  TestUI.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/18/24.
//

import SwiftUI


struct TestUI: View {
    var body: some View {
        GeometryReader{ geo in
            ZStack{
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(Color.blue)
                    .padding([.leading, .trailing],10)
                TestGeo(geo: geo)
            }
        }
    }
}

struct TestGeo: View {
    @State var geo: GeometryProxy
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color.green)
            .frame(width: geo.size.width / 2, height: geo.size.height / 2)
    }
}

#Preview {
    TestUI()
}
