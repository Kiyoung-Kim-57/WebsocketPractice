//
//  UpbitManager.swift
//  WebsocketProject
//
//  Created by 김기영 on 5/10/24.
//

import Foundation
import Combine

class UpbitManager: NSObject, URLSessionWebSocketDelegate {
    static let shared = UpbitManager()
    
    private var timer: Timer?
    private var websocket: URLSessionWebSocketTask?
    
    var isConnect = false
    var dataPassThrough = PassthroughSubject<TickerModel, Never>()
    
    var marketData: [MarketModel] = [
        .init(id: UUID(), code: "KRW-BTC", korName: "비트코인", engName: "Bitcoin")
    ]
    
    private override init() {
        super.init()
    }
    
    //Url Components
    var url: URL {
        var coinUrlComponent: URLComponents {
            var urlCom = URLComponents()
            urlCom.scheme = "wss"
            urlCom.host = "api.upbit.com"
            return urlCom
        }
        
        var components = coinUrlComponent
        components.path = "/websocket/v1"
        return components.url!
    }
    
    func connect() {
        print(#function)
        let request = URLRequest(url: url)
        
        websocket = URLSession.shared.webSocketTask(with: request)
        websocket?.resume()
        receiveMessage()
        
        isConnect = true
        ping()
    }
    
    func disconnect() {
        print(#function)
        websocket?.cancel()
        isConnect = false
    }
    
    
    func sendMessage(_ market: String) {
        print(#function)
        guard let websocket = websocket else { return }
        let message = """
        [{"ticket":"test"},{"type":"ticker","codes":["\(market)"]}]
    """
        
        websocket.send(URLSessionWebSocketTask.Message.string(message), completionHandler: { error in
            if let error = error {
                print("error occured in '\(#function)' : \(error.localizedDescription)")
            }
        })
    }
    
    func receiveMessage() {
        print(#function)
        guard let websocket = websocket else { return }
        
        websocket.receive(completionHandler: { [weak self] result in
            switch result {
                //데이터를 전송 받고
            case .success(let success):
                switch success {
                case .data(let data):
                    do {
                        let ticker = try JSONDecoder().decode(TickerModel.self, from: data)
                        self?.dataPassThrough.send(ticker)
                    } catch {
                        print("error occured in '\(#function)' : \(error.localizedDescription)")
                    }
                default:
                    print("Error")
                    break
                }
            case .failure(let error):
                //실패시 코드 작동
                print("error occured in '\(#function)' : \(error.localizedDescription)")
                return
            }
            
            self?.receiveMessage()
        })
    }
    
    private func ping() {
        print(#function)
        //연결되어 있을 동안에만 작동
        if isConnect {
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
                self?.websocket?.sendPing(pongReceiveHandler: { error in
                    if let error = error {
                        print("error occured in '\(#function)' : \(error.localizedDescription)")
                    } else {
                        print("pong")
                    }
                })
            })
        } else {
            //연결되어 있지 않은 경우 타이머 초기화
            timer?.invalidate()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print(#function)
        print("urlSession Start")
        receiveMessage()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print(#function)
        print("WebSocket Closed")
    }
    
    
}
