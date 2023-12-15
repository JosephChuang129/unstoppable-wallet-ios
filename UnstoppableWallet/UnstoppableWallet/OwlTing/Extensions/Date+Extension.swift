import Foundation

extension Date {
    
    var oneYearAfter: Date {
        let day = Calendar.current.date(byAdding: .year, value: -18, to: self)
        return day!
    }
    
    static func +(_ date: Date, _ amount: Calendar.ComponentWithValue) -> Date {
        Calendar.current.date(byAdding: amount.component, value: amount.value, to: date)!
    }

    static func +(_ amount: Calendar.ComponentWithValue, _ date: Date) -> Date {
        date + amount
    }

    static func +=(_ date: inout Date, _ amount: Calendar.ComponentWithValue) {
        date = date + amount
    }
    
    static func -(_ date: Date, _ amount: Calendar.ComponentWithValue) -> Date {
        Calendar.current.date(byAdding: amount.component, value: -amount.value, to: date)!
    }

    static func -(_ amount: Calendar.ComponentWithValue, _ date: Date) -> Date {
        date - amount
    }

    static func -=(_ date: inout Date, _ amount: Calendar.ComponentWithValue) {
        date = date - amount
    }
}
