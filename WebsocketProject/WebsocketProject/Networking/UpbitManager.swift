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
    //받아온 데이터를 사용할 서브젝트
    var dataPassThrough = PassthroughSubject<TickerModel, Never>()
    
    var marketData: [MarketModel] = [
        .init(code: "KRW-ETC", korName: "비트코인", engName: "Bitcoin"),
        .init(code: "KRW-ETH", korName: "이더리움", engName: "Ethereum")
    ]
    
    
    private override init() {
        super.init()
    }
    
    //Url Components
    var coinUrlComponent: URLComponents {
        var urlCom = URLComponents()
        urlCom.scheme = "wss"
        urlCom.host = "api.upbit.com"
        return urlCom
    }
    //Url for Websocket
    var webSocketUrl: URL {
        var components = coinUrlComponent
        components.path = "/websocket/v1"
        return components.url!
    }
    //Url for Http
    var httpUrl: URL {
        var components = coinUrlComponent
        components.scheme = "https"
        components.path = "/v1/market/all"
        return components.url!
    }
    
    func marketCodesRequest(completion: @escaping (Result<[MarketModel], ConnectError>) -> Void) {
        let request = URLRequest(url: httpUrl)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else { return completion(.failure(.connectError)) }
            
            let marketResponse = try? JSONDecoder().decode([MarketModel].self , from: data)
            
            if let market = marketResponse {
                completion(.success(market))
            } else {
                completion(.failure(.connectError))
                print("decoding error")
            }
        }.resume()
    }
    
    
    
    func connect() {
        print(#function)
        let request = URLRequest(url: webSocketUrl)
        
        websocket = URLSession.shared.webSocketTask(with: request)
        websocket?.resume()
        
        isConnect = true
        ping()
    }
    
    func disconnect() {
        print(#function)
        websocket?.cancel()
        isConnect = false
        timer?.invalidate()
    }
    
    
    func sendMessage(_ market: String) {
//        print(#function)
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
    
    func receiveMessage(subject: PassthroughSubject<TickerModel, Never>) {
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
                        subject.send(ticker)
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
            //지속적인 메시지 수신
            self?.receiveMessage(subject: subject)
        })
    }
    
    private func ping() {
//        print(#function)
        //연결되어 있을 동안에만 작동
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            self?.websocket?.sendPing(pongReceiveHandler: { error in
                if let error = error {
                    print("error occured in '\(#function)' : \(error.localizedDescription)")
                } else {
                    print("pong")
                }
            })
        })
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print(#function)
        print("urlSession Start")
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print(#function)
        print("WebSocket Closed")
    }
    
    
}


extension UpbitManager {
    enum ConnectError: Error {
        case connectError
    }
    
    //WatchOS용 https 통신
    
}
