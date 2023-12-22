
import Combine
import BigInt
import stellarsdk
import MarketKit
import RxSwift
import RxCocoa

class StellarAddressParser: IAddressParserItem {

    private let stellarAdapter: StellarAdapter
    
    init(stellarAdapter: StellarAdapter) {
        self.stellarAdapter = stellarAdapter
    }
    
    func handle(address: String) -> Single<Address> {
        
        return Single.create { single in
            self.stellarAdapter.stellarKitWrapper.stellarKit.stellarKitProvider.isValidAccount(id: address) { result in
                switch result {
                case .success(let isValid):
                    // 驗證成功，發送 true
                    if isValid {
                        single(.success(Address(raw: address, domain: nil)))
                    }
                case .failure(let error):
                    // 驗證失敗，發送錯誤
                    single(.error(error))
                }
            }
            // Disposable 在這裡可以用來取消非同步操作，這裡簡單地返回一個空的 Disposable
            return Disposables.create()
        }
    }

    func isValid(address: String) -> Single<Bool> {
        return Single.create { single in
            self.stellarAdapter.stellarKitWrapper.stellarKit.stellarKitProvider.isValidAccount(id: address) { result in
                switch result {
                case .success(let isValid):
                    // 驗證成功，發送 true
                    single(.success(isValid))
                case .failure(let error):
                    // 驗證失敗，發送錯誤
                    single(.error(error))
                }
            }
            // Disposable 在這裡可以用來取消非同步操作，這裡簡單地返回一個空的 Disposable
            return Disposables.create()
        }
    }
    
    private func validate(address: String) -> Single<Address> {
        return Single.just(Address(raw: address, domain: nil))
    }
}
