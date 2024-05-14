////
////  WebsocketManager.swift
////  WebsocketProject
////
////  Created by 김기영 on 5/7/24.
////
//
//import Foundation
////Swift has no local JWT library
//import Combine
//import SwiftJWT
//
//class WebsocketManager: NSObject, URLSessionWebSocketDelegate, ObservableObject {
//    //Websocket task
//    var websocketTask: URLSessionWebSocketTask!
//    //To Check connection
//    @Published var isConnect: Bool = false
//    //Present Price Data from Upbit WebSocket Server
//    @Published var priceData: PriceModel?
//    //Api Key
//    var coinApiKey: String? {
//        return Bundle.main.coinApiKey
//    }
//    var secretKey: String? {
//        return Bundle.main.secretKey
//    }
//    //Url Components
//    var coinUrlComponent: URLComponents {
//        var urlCom = URLComponents()
//        urlCom.scheme = "wss"
//        urlCom.host = "api.upbit.com"
//        return urlCom
//    }
//    
//    func connect() {
//        var urlComponenet = coinUrlComponent
//        urlComponenet.path = "/websocket/v1"
//        guard let url = urlComponenet.url, let apiKey = coinApiKey, let secretKey = secretKey else { return } //optional unwrapping
//        var request = URLRequest(url: url)
//        //payload 만들어 접근
//        let payload = Payload(accessKey: apiKey, nonce: UUID().uuidString)
//        var jwt = JWT(claims: payload)
//        let signedJwt = try! jwt.sign(using: .hs256(key: Data(secretKey.utf8)))
//        //Set value of request
//        request.setValue("Bearer \(signedJwt)", forHTTPHeaderField: "Authorization")
//        //Making WebSocket Task
//        websocketTask = URLSession.shared.webSocketTask(with: request)
//        websocketTask.resume()
//        print("is connect?")
////        sendMessage()
//        receiveMessage()
//        isConnect = true
//    }
//    
//    func disconnect() {
//        websocketTask.cancel()
//        isConnect = false
//    }
//    func sendMessage() {
//        let message = URLSessionWebSocketTask.Message.string("""
//                                                             [{"ticket": "test example"},{"type": "ticker","codes": ["KRW-BTC"] }, {"format": "DEFAULT"}]
//        """)
//        websocketTask.send(message) { error in
//            if let error = error {
//                print("Error occured: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func receiveMessage() {
//        websocketTask.receive { [weak self] result in
//            //guard let 옵셔널 언래핑을 통해 옵셔널 체이닝
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let message):
//                switch message {
//                case .data(let data):
//                    DispatchQueue.main.async {
//                        do {
//                            self.priceData = try JSONDecoder().decode(PriceModel.self, from: data)
//                            self.receiveMessage()
//                        } catch {
//                            print("Json Decoding Error Occured")
//                        }
//                    }
//                default:
//                    break
//                }
//            case .failure(let error):
//                print("error: \(error.localizedDescription)")
//            }
//        }
//    }
//    //After connection with webSocket
//    //sendMessage Method is needed only when it connects to websocket server initially, after connection receiveMessage method will get data from server
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
//        print("Websocket is connected!")
//        sendMessage()
//    }
//    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
//        if let error = error {
//            print("is this?")
//            print("error occured : \(error.localizedDescription)")
//        } else {
//            print("WebSocket task completed")
//        }
//    }
//    
//    
//    
//}
//
////About JWT
//extension WebsocketManager {
//    
//    //JWT에 사용될 payload
//    struct Payload: Claims {
//        let accessKey: String
//        let nonce: String
////        let queryHash: String
////        let queryHashAlg: String
//        
//        enum ClaimsValue: String, CodingKey {
//            case accessKey = "access_key" //필수
//            case nonce = "nonce" //필수
////            case queryHash = "query_hash" //파라미터가 있을 경우에 필수
////            case queryHashAlg = "query_hash_alg"
//        }
//    }
//}
