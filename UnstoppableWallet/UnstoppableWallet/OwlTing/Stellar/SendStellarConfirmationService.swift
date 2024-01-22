import Foundation
import MarketKit
import RxSwift
import RxCocoa
import BigInt
import HsExtensions
import Combine

class SendStellarConfirmationService {
    private var tasks = Set<AnyTask>()
    
    private let feeService: SendFeeService
    private let stellarKitWrapper: StellarKitWrapper
    private let evmLabelManager: EvmLabelManager
    private let stateRelay = PublishRelay<State>()
    private(set) var state: State = .notReady(errors: []) {
        didSet {
            stateRelay.accept(state)
        }
    }
    
    let feeStateRelay = BehaviorRelay<DataStatus<Decimal>>(value: .loading)
    var feeState: DataStatus<Decimal> = .loading {
        didSet {
            if !feeState.equalTo(oldValue) {
                feeStateRelay.accept(feeState)
            }
        }
    }
    
    private let sendAdressActiveRelay = PublishRelay<Bool>()
    private(set) var sendAdressActive: Bool = true {
        didSet {
            sendAdressActiveRelay.accept(sendAdressActive)
        }
    }
    
    private(set) var sendData: StellarSendData
    private(set) var token: Token
    private(set) var dataState: DataState
    
    private let sendStateRelay = PublishRelay<SendState>()
    private(set) var sendState: SendState = .idle {
        didSet {
            sendStateRelay.accept(sendState)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    init(sendData: StellarSendData, stellarKitWrapper: StellarKitWrapper, feeService: SendFeeService, evmLabelManager: EvmLabelManager, token: Token) {
        self.sendData = sendData
        self.stellarKitWrapper = stellarKitWrapper
        self.feeService = feeService
        self.evmLabelManager = evmLabelManager
        self.token = token
        
        dataState = DataState(sendData: sendData)
        
        feeService.feeValueService = self
        syncFees()
        syncAddress()
    }
    
    private var stellarKit: StellarKit {
        stellarKitWrapper.stellarKit
    }
    
    private func syncFees() {
        
        feeState = .completed(Decimal(0.1))
        
        let totalFee = BigUInt(1000000)
        let balance = stellarKit.balance
        let nativeBalance = stellarKit.nativeBalance
        
//        print("token.type = \(token.type)")
//        print("totalFee = \(totalFee)")
//        print("balance = \(balance)")
//        print("nativeBalance = \(nativeBalance)")
//        print("default BigUInt(sendData.value) = \(BigUInt(sendData.value))")
        
        if token.type == .native {
            
            var totalAmount = BigUInt(0)
            
            var sentAmount = BigUInt(sendData.value)
            let minimumExistBalance = BigUInt(10000000)
            let subentriesBalance = BigUInt(5000000)
            
            let minBalance = minimumExistBalance + subentriesBalance + totalFee
//            let maxBalance = nativeBalance - minimumExistBalance - subentriesBalance - totalFee
            var maxBalance: BigUInt = 0
            if minBalance < nativeBalance {
                maxBalance = nativeBalance - minBalance
            }

            if sentAmount > maxBalance {

                sentAmount = maxBalance
                guard sentAmount > 0 else {
//                    state = .notReady(errors: [TransactionError.zeroAmount])
                    state = .notReady(errors: [TransactionError.insufficientBalance(balance: "")])
                    return
                }
                
                sendData.value = Int(sentAmount)
                dataState = DataState(sendData: sendData)
            }
            
            totalAmount += sentAmount

            if maxBalance < totalAmount {
//                state = .notReady(errors: [TransactionError.insufficientBalance(balance: nativeBalance)])
                state = .notReady(errors: [TransactionError.insufficientBalance(balance: "")])
                return
            }
            
            state = .ready
            
            // 1
//            var sentAmount = BigUInt(sendData.value)
//            
//            if (sentAmount + totalFee) > nativeBalance {
////                state = .notReady(errors: [TransactionError.zeroAmount])
//                state = .notReady(errors: [TransactionError.insufficientBalance(balance: "")])
//            } else {
//                state = .ready
//            }
            
            // 2
//            let maxBalance = nativeBalance - minimumExistBalance - subentriesBalance - totalFee
//
//            if nativeBalance == sentAmount {
//
////                sentAmount = sentAmount - minimumExistBalance - subentriesBalance - totalFee
//                sentAmount = maxBalance
//                guard sentAmount > 0 else {
//                    state = .notReady(errors: [TransactionError.zeroAmount])
//                    return
//                }
//
//                sendData.value = Int(sentAmount)
//                dataState = DataState(sendData: sendData)
//            }
//
//            totalAmount += sentAmount
//            totalAmount += totalFee
//
//            if nativeBalance < totalAmount {
////                state = .notReady(errors: [TransactionError.insufficientBalance(balance: nativeBalance)])
//                state = .notReady(errors: [TransactionError.insufficientBalance(balance: "")])
//                return
//            }
//
//            state = .ready
            
        } else {
            
            if totalFee > nativeBalance {
//                state = .notReady(errors: [TransactionError.insufficientBalance(balance: totalFee)])
                state = .notReady(errors: [TransactionError.insufficientBalance(balance: "")])
            } else {
                state = .ready
            }
        }
    }
    
    private func syncAddress() {
        sendAdressActive = true
    }
}

extension SendStellarConfirmationService: ISendXFeeValueService {
    
    var feeStateObservable: Observable<DataStatus<Decimal>> {
        feeStateRelay.asObservable()
    }
}

extension SendStellarConfirmationService {
    
    var stateObservable: Observable<State> {
        stateRelay.asObservable()
    }
    
    var sendStateObservable: Observable<SendState> {
        sendStateRelay.asObservable()
    }
    
    var sendAdressActiveObservable: Observable<Bool> {
        sendAdressActiveRelay.asObservable()
    }
    
    func send() {
        
        sendState = .sending
        
        let amount = Decimal(bigUInt: BigUInt(sendData.value), decimals: token.decimals) ?? 0
        stellarKit.stellarKitProvider.send(destinationAccountId: sendData.to, amount: amount, token: token)
            .subscribe(onSuccess: { [weak self] in
                self?.sendState = .sent
                
            }, onError: { [weak self] error in
                self?.sendState = .failed(error: error)
            })
            .disposed(by: disposeBag)
    }
    
}

extension SendStellarConfirmationService {
    
    enum State {
        case ready
        case notReady(errors: [Error])
    }
    
    struct DataState {
        let sendData: StellarSendData
    }
    
    enum SendState {
        case idle
        case sending
        case sent
        case failed(error: Error)
    }
    
    enum TransactionError: Error {
        case insufficientBalance(balance: BigUInt)
        case zeroAmount
    }
    
}
