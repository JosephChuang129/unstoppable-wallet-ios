import LanguageKit

class OwlTingLunchService {
    
    init() {}
}

extension OwlTingLunchService {

    var langCode: String {
        LanguageManager.shared.currentLanguage.langCode
    }
}
