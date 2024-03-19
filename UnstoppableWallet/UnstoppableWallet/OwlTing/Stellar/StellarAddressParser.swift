
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
        
        do {
            let _ = try KeyPair(accountId: address)
            return Single.just(Address(raw: address))
        } catch {
            return Single.error(error)
        }
    }

    func isValid(address: String) -> Single<Bool> {
        do {
            let _ = try KeyPair(accountId: address)
            return Single.just(true)
            
        } catch {
            return Single.just(false)
        }
    }
    
    private func validate(address: String) -> Single<Address> {
        return Single.just(Address(raw: address, domain: nil))
    }
}
