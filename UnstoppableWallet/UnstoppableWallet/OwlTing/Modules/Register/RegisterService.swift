import UIKit
import LanguageKit

class RegisterService {
    
    let networkService: NetworkService
    private let accountManager: AccountManager
    
    init(networkService: NetworkService, accountManager: AccountManager) {
        self.networkService = networkService
        self.accountManager = accountManager
    }
}

extension RegisterService {

    func storeUserData(response: OTWalletRegisterResponse) {
        
        accountManager.currentLoginState = true
        accountManager.otWalletToken = response.token
        accountManager.customer = response.customer
    }
    
    var langCode: String {
        LanguageManager.shared.currentLanguage.langCode
    }
}
