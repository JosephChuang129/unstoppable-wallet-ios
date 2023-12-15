//
//  PublicVariables.swift
//

import Foundation
import UIKit

struct Constants {
    static let imageFadeTimeInterval = 0.4
    static let phonePrefix = "tel://"
    
}

struct InputsLengthLimit {
    static let phoneInputs = 7
}

struct WebLink {
    
    static let url = ""
}

struct AppStore {
    static let googleMapURL = "itms-apps://itunes.apple.com/app/id"
}

struct APIParameter {
    static let defaultPage = 1
    static let defaultLimit = 10
}

enum ResponseStatus: Int {
    case success = 200
    static func fetchRaw(_ theEnum: ResponseStatus) -> Int {
        return theEnum.rawValue
    }
}

enum ErrorResult: Error {
    case networkError
    case serverError(string: String?)
    case customError(string: String?)
}
