import Foundation

extension Int {
    var days: Calendar.ComponentWithValue {
        .init(component: .day, value: self)
    }
    
    var months: Calendar.ComponentWithValue {
        .init(component: .month, value: self)
    }
    
    var years: Calendar.ComponentWithValue {
        .init(component: .year, value: self)
    }
}


