import UIKit
import LanguageKit

class LoginService {
    
    let networkService: NetworkService
    private let accountManager: AccountManager
    let walletManager: WalletManager
    let adapterManager: AdapterManager

    init(networkService: NetworkService, accountManager: AccountManager, walletManager: WalletManager, adapterManager: AdapterManager) {
        self.networkService = networkService
        self.accountManager = accountManager
        self.walletManager = walletManager
        self.adapterManager = adapterManager
    }

    var accounts: [Account] {
        accountManager.accounts
    }
}

extension LoginService {

    var activeAccount: Account? {
        accountManager.activeAccount
    }
    
    var currentLoginState: Bool {
        accountManager.currentLoginState
    }
    
    func storeUserData(response: OTWalletLoginResponse) {
        
        accountManager.currentLoginState = true
        accountManager.otWalletToken = response.token
        accountManager.customer = response.customer
    }
    
    func storeAmlMeta(response: AmlUserMetaResponse) {
        accountManager.saveAmlUserMeta(response: response)
    }
    
    func finishFlow() {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: MainModule.instance(presetTab: .settings))
    }
}

extension LoginService {

    var langCode: String {
        LanguageManager.shared.currentLanguage.langCode
    }
}
