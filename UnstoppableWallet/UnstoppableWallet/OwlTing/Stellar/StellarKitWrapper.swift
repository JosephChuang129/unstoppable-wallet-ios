
import Foundation
import MarketKit

class StellarKitWrapper {
    let blockchainType: BlockchainType
    let stellarKit: StellarKit
    let token: Token

    init(blockchainType: BlockchainType, stellarKit: StellarKit, token: Token) {
        self.blockchainType = blockchainType
        self.stellarKit = stellarKit
        self.token = token
    }
    
    func send(sendData: StellarSendData) async throws {
        
    }
}
