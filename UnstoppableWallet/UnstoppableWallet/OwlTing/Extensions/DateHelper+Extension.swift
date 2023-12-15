import Foundation

extension DateHelper {
    
    static let yyyyMMdd = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
    }
    
    func formatOTDate(from date: Date) -> String {
        return DateHelper.yyyyMMdd.string(from: date)
    }
}
