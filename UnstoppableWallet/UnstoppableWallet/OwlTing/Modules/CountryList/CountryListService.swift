import LanguageKit

class CountryListService {
    
    let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
}

extension CountryListService {
    
    var langCode: String {
        LanguageManager.shared.currentLanguage.langCode
    }
}
