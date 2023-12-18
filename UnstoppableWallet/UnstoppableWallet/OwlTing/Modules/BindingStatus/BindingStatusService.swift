import UIKit
import MarketKit

class BindingStatusService {
    
    private let accountManager: AccountManager
    private let walletManager: WalletManager
    private let marketKit: MarketKit.Kit
    let networkService: NetworkService
    var items: [BindingStatusService.Item] = []
    private(set) var activeSsoUserChain: [SSOUserChain] = []
    private var chainImageUrlMap: [String: String] = ["USDC": "usd-coin", "ETH": "ethereum", "MATIC": "matic-network", "AVAX": "avalanche-2"]
    
    init(walletManager: WalletManager, accountManager: AccountManager, networkService: NetworkService, marketKit: MarketKit.Kit) {
        self.accountManager = accountManager
        self.walletManager = walletManager
        self.networkService = networkService
        self.marketKit = marketKit

        syncItems()
    }
    
    deinit {
        //Dprint("\(type(of: self)) \(#function)")
    }
}

extension BindingStatusService {
    
    private func syncItems() {
        
        // 此錢包所有法幣 chain，只取出 polygon avalanche ethereum 鏈種
        let wallets = walletManager.activeWallets.filter { wallet in
            let blockchainType = wallet.token.blockchainType
            return blockchainType == .polygon || blockchainType == .avalanche || blockchainType == .ethereum
        }
        
        activeSsoUserChain = wallets.compactMap { wallet in
            generateChain(wallet: wallet)
        }
        
//        activeSsoUserChain = walletManager.activeWallets.compactMap { wallet in
//            generateChain(wallet: wallet)
//        }

        // 此錢包未綁定到 aml 上的 chain
        let unBindingChains = activeSsoUserChain.filter { chain in
            !(amlUserMeta?.ssoUserChains ?? []).contains(chain)
        }

        let supportedTokens = fetchFullCoins().flatMap { fullCoin in
            fullCoin.tokens
        }

        let tokens = supportedTokens.filter { token in
            (token.blockchainType == .polygon) || (token.blockchainType == .ethereum) || (token.blockchainType == .avalanche)
        }

        let unBindingItems = unBindingChains.map { chain in
            BindingStatusService.Item(chain: chain, imgUrl: getChainImageUrl(chain: chain), chainStatus: getChainStatus(chain: chain), wallet: chain.wallet)
        }

        var activeItems: [BindingStatusService.Item] = []
        if let account = accountManager.activeAccount {

            for chain in (amlUserMeta?.ssoUserChains ?? []) {

                for token in tokens {

                    if chain.chainAsset == token.coin.code, chain.chainNetwork == token.blockchain.name {
                        let wallet = Wallet(token: token, account: account)
                        activeItems.append(BindingStatusService.Item(chain: chain, imgUrl: getChainImageUrl(chain: chain), chainStatus: getChainStatus(chain: chain), wallet: wallet))

                    }

                }
            }
        }

        // aml 審核過的 chain + 此錢包目前的 chain 統整
        items = activeItems + unBindingItems
    }
    
    private func generateChain(wallet: Wallet) -> SSOUserChain? {
        
        guard let adapter = App.shared.adapterManager.depositAdapter(for: wallet) else { return nil }
        var chain = SSOUserChain()
        chain.chainAddress = adapter.receiveAddress.address
        chain.chainAsset = wallet.token.coin.code
        chain.chainNetwork = wallet.token.blockchain.name
        chain.wallet = wallet
        
        return chain
    }
    
    private func getChainStatus(chain: SSOUserChain) -> ChainStatus {
        guard activeSsoUserChain.contains(chain) else {
            return .notInThisWallet
        }
        return chain.chainIsBinding == true ? .binding : .unBinding
    }
    
    private func getChainImageUrl(chain: SSOUserChain) -> String? {
        
        if let asset = chain.chainAsset, let uid = chainImageUrlMap[asset] {
            let scale = Int(UIScreen.main.scale)
            return "https://cdn.blocksdecoded.com/coin-icons/32px/\(uid)@\(scale)x.png"
        }
        
        return nil
    }
    
    private func fetchFullCoins() -> [FullCoin] {
        
        do {
            
            let coinUids: [String] = ["ethereum", "avalanche-2", "matic-network", "usd-coin"]
            let coins = try marketKit.fullCoins(coinUids: coinUids)
            
            let fullCoins = coins.map { fullCoin in
                
                switch fullCoin.coin.code {
                case "ETH":
                    return FullCoin(coin: fullCoin.coin, tokens: fullCoin.tokens.filter { $0.blockchainType == .ethereum})
                    
                case "AVAX", "MATIC":
                    return FullCoin(coin: fullCoin.coin, tokens: fullCoin.tokens.filter { $0.type == .native})
                
                default:
                    
                    let tokens = fullCoin.tokens.filter { token in
                        (token.blockchainType == .polygon) || (token.blockchainType == .ethereum) || (token.blockchainType == .avalanche)
                    }
                    return FullCoin(coin: fullCoin.coin, tokens: tokens)
                }
            }

            return fullCoins
            
        } catch {
            return []
        }
        
    }
}

extension BindingStatusService {
    
    var activeWallets: [Wallet] {
        walletManager.activeWallets
    }
    
    var amlUserMeta: AmlUserMeta? {
        accountManager.amlUserMeta
    }
}

extension BindingStatusService {
    
    struct Item {
        var chain: SSOUserChain
        var imgUrl: String?
        var chainStatus: ChainStatus
        var wallet: Wallet?
    }
    
}


enum ChainStatus: String {
    case binding
    case unBinding
    case notInThisWallet
    
    func title() -> String {
        switch self {
        case .binding: return "binding_chain_status.binding".localized
        case .unBinding: return "binding_chain_status.unBinding".localized
        case .notInThisWallet: return "binding_chain_status.not_in_this_wallet".localized
        }
    }
    
    func color() -> UIColor {
        switch self {
        case .binding: return .themeGreenD
        case .unBinding: return .themeLeah
        case .notInThisWallet: return .themeLeah
        }
    }
    
    static func fetchRaw(_ theEnum: AmlValidateStatus) -> String {
        return theEnum.rawValue
    }
}
