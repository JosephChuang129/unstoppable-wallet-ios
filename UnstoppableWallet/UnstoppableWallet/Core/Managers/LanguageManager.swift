import Foundation
import LanguageKit

extension String {

    var localized: String {
        LanguageManager.shared.localize(string: self, bundle: Bundle.main)
    }

    func localized(_ arguments: CVarArg...) -> String {
        LanguageManager.shared.localize(string: self, bundle: Bundle.main, arguments: arguments)
    }

    var langCode: String {
        
        switch LanguageManager.shared.currentLanguage {
        case "zh-Hant", "zh":
            return "zh_tw"
        default:
            return LanguageManager.shared.currentLanguage
        }
    }
}
