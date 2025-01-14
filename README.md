# 개요

웹소켓 통신을 이용해서 실시간으로 변하는 코인의 가격 정보를 받아오고 그 정보를 토대로 간단한 1분봉 혹은 n초봉의 그래프를 보여주는 간단한 프로젝트
iOS에서 웹소켓 통신 활용을 학습해보고 실시간으로 들어오는 데이터를 Combine을 통해 바인딩하여 뷰에 적용하는 연습을 위해 시작한 학습용 프로젝트이다. 

# 목표

- [x] WebSocket 통신 익히기 /check
- [x] Combine을 사용해서 들어오는 정보 처리해보기
- [x] 들어오는 정보를 토대로 실시간으로 기록되는 코인 차트 따라 만들어보기
- [ ] 위젯 또는 워치를 통해 간단히 확인할 수 있는 화면 구현해보기
    - [x] 워치용 뷰 구현
    - [ ] 워치에서 웹소켓 통신

## Pepe’s Coin Check

업비트 웹소켓을 통해서 실시간 가격을 받아오고 이를 토대로 5초 간격으로 업데이트 되는 음양봉 그래프(주식 또는 코인에서 등락의 변화량을 볼 수 있는 그래프)를 그리고 오르고 내릴때마다 페페 개구리 이미지 보이기

- **작동영상**
    
|iOS에서 작동|watchOS(시뮬에서만 동작)|
|------------|-------------------------------------------|
|![](https://i.imgur.com/5rwvP26.gif)|![](https://i.imgur.com/Kl6C274.gif)|


    

### 사용기능

1. `웹소켓` 통신(업비트 웹소켓)
2. `https` 통신 → 업비트에서 거래되는 코인 목록 받아오기
3. `Combine` → 웹소켓에서 오는 데이터를 실시간으로 반영하고 일정 시간 간격으로 추가적인 데이터 처리
- 실시간 변동 차트 막대 & 5초마다 저장되고 업데이트 되는 차트
4. `WatchOS` 간단한 뷰 그려보기
- 전처리 #if문을 통해 같은 앱으로 iOS, watchOS 따로 구현될 수 있게 만들기

### 트러블 슈팅

1. **웹소켓 통신 실패**
    
    `원인` → 데이터 모델을 Postman에서 응답 받은 값을 토대로 만들었는데 코인 종류에 따라서 안쓰는 변수가 있어서 일정 코인 데이터에서 응답 오류 발생
    
    `해결` → 실제로 사용할 변수들만 남기고 데이터 모델 정리
    
2. **뷰모델 객체들이 같은 데이터를 공유하고 있는 오류**
    
    `증상`: 가격에 비례해서 차트 막대 길이가 조절되는데 여러 데이터가 섞이니 차트 길이도 뒤죽박죽
    
    `원인`: 문제 원인은 데이터를 처리하는 Combine 의 Subject가 싱글톤으로 구현된 웹소켓 매니저 클래스에 있었던 것 → 그래서 모든 뷰모델 객체에 같은 데이터들이 들어가고 있던 것
    
    `해결`: Subject를 뷰모델로 옮겨서 각 뷰모델 객체마다 따로 데이터를 처리하도록 변경하여 오류 수정(웹소켓 매니저를 굳이 싱글톤으로 구현해야하나 고민 필요)
    
3. **실제 애플 워치 기기에서 웹소켓 통신이 안되는 오류**
    
    `증상`: 코인 목록을 불러오는 Https 통신은 성공적으로 됐는데 웹소켓으로 데이터를 불러오는 과정은 실패
    
    `원인`: 검색해보니 특정 OS버전 이후부터 웹소켓 통신은 워치 자체에서는 지원이 안됨(그 외 low-level networking도 작동하지 않음)
    
    그런데 또 검색해보니 WatchOS7부터 Websocket 통신을 지원했다는데 왜 안되는지 명확한 이유를 찾지 못했다.
    
    `해결`: 주기적으로 http 통신을 통해 현재 가격을 불러오거나 Watch connectivity를 사용하면 해결할 수 있을 것으로 보임(미해결)

### WebSocket Manager

- 업비트(코인거래소)의 웹소켓 서버에 연결해서 데이터를 받아오는 웹소켓 매니저

```swift
import Foundation
import Combine

class UpbitManager: NSObject, URLSessionWebSocketDelegate {
//싱글톤 패턴
    static let shared = UpbitManager()
    
    //ping을 주기적으로 보내기 위한 타이머
    private var timer: Timer?
    private var websocket: URLSessionWebSocketTask?
    
    var isConnect = false
    //받아온 데이터를 사용할 서브젝트 퍼블리셔
    var dataPassThrough = PassthroughSubject<TickerModel, Never>()
    //뷰모델에 전달할 임시 마켓 데이터
    var marketData: [MarketModel] = [
        .init(id: UUID(), code: "KRW-BTC", korName: "비트코인", engName: "Bitcoin"),
        .init(id: UUID(), code: "KRW-ETH", korName: "이더리움", engName: "Ethereum")
    ]
    //싱글톤 패턴 용으로 사용하는 이니셜라이저
    private override init() {
        super.init()
    }
    
    //Url Components - upbit api는 가격 확인만 할 때는 따로 개인 apikey가 필요하진 않았음
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
    //웹소켓 연결
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
        websocket?.cancel()
        isConnect = false
        timer?.invalidate()
    }
    
    
    func sendMessage(_ market: String) {
    //연결된 웹소켓에 메시지 전달
        print(#function)
        guard let websocket = websocket else { return }
        let message = """
        [{"ticket":"test"},{"type":"ticker","codes":["\\(market)"]}]
    """
        
        websocket.send(URLSessionWebSocketTask.Message.string(message), completionHandler: { error in
            if let error = error {
                print("error occured in '\\(#function)' : \\(error.localizedDescription)")
            }
        })
    }
    
    func receiveMessage() {
    //메시지 전달 후 데이터를 웹소켓 서버로부터 수신
        guard let websocket = websocket else { return }
        //캡쳐 리스트에 weak self 선언해서 약한 참조
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
                        print("error occured in '\\(#function)' : \\(error.localizedDescription)")
                    }
                default:
                    print("Error")
                    break
                }
            case .failure(let error):
                //실패시 코드 작동
                print("error occured in '\\(#function)' : \\(error.localizedDescription)")
                return
            }
            //지속적인 메시지 수신
            self?.receiveMessage()
        })
    }
    //업비트 웹소켓은 120초 동안 응답이 없으면 자동으로 연결이 해제되어 지속적인 연결을 위해 ping을 사용
    private func ping() {
        //연결되어 있을 동안에만 작동
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            self?.websocket?.sendPing(pongReceiveHandler: { error in
                if let error = error {
                    print("error occured in '\\(#function)' : \\(error.localizedDescription)")
                } else {
                    print("pong")
                }
            })
        })
        
    }
    //TODO: 이 밑 부분은 실행이 안되던데 확인해봐야함
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) { ... }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) { ... }
    
    
}

```

### WebSocket ViewModel with Combine

```swift
import Foundation
import Combine

class UpbitViewModel: ObservableObject {
//TickerModel은 웹소켓에서 받은 데이터를 담는 모델
    @Published var presentPrice: TickerModel?
    //테스트용 모델 데이터들, 실제 구동할 땐 웹소켓 서버에서 받아온 데이터 사용 예정
    @Published var chartData: [CoinChartsData] = [
        .init(id: UUID(), presentPrice: 10, prevPrice: 5, highestPrice: 12, lowestPrice: 3),
        .init(id: UUID(), presentPrice: 12, prevPrice: 10, highestPrice: 15, lowestPrice: 8),
        .init(id: UUID(), presentPrice: 8, prevPrice: 12, highestPrice: 13, lowestPrice: 7),
        .init(id: UUID(), presentPrice: 19, prevPrice: 8, highestPrice: 21, lowestPrice: 13),
        .init(id: UUID(), presentPrice: 5, prevPrice: 19, highestPrice: 20, lowestPrice: 3)
    ]
    var prevPrice: Double?
    var isPrevChecked = true
    //마켓은 뷰모델이 어떤 시장(비트코인, 이더리움 등)의 코인을 보여주는지를 결정하는 변수
    var market: MarketModel
    var cancellable = Set<AnyCancellable>()
    
    init(market: MarketModel) {
        self.market = market
        //객체가 생성될 때 웹소켓에 연결 후 메시지 전송
        UpbitManager.shared.connect()
        UpbitManager.shared.sendMessage(market.code)
        //업비트매니저에 있는 퍼블리셔를 구독
        UpbitManager.shared.dataPassThrough
            .receive(on: DispatchQueue.main) //받아오는 변수들을 바로 뷰에 적용할거라 메인 스레드에서 진행
            .sink { [weak self] ticker in
                guard let self = self else { return }
                self.presentPrice = ticker
                //첫 가격을 저장하기 위해 설정
                if isPrevChecked {
                    self.prevPrice = ticker.tradePrice
                }
                isPrevChecked = false
            }
            .store(in: &cancellable)
    }
    //객체가 메모리에서 해제되면 웹소켓 연결도 해제
    //프리뷰에서는 다른 창으로 넘어가도 객체가 해제가 안돼서 연결해제를 직접해야함..
    deinit {
        UpbitManager.shared.disconnect()
    }
}
```
