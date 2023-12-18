//
//  Observable+ObjectMapper.swift
//

import Foundation
import Moya
import ObjectMapper
import RxSwift

enum RxSwiftMoyaError: Swift.Error {
    case ParseJSONError
    case NoRepresentor
    case NotSuccessfulHTTP
    case NoData
    case CouldNotMakeObjectError
    case InvalidAccess
    case BizError(resultCode: String, resultMsg: String)
}

extension RxSwiftMoyaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .ParseJSONError:
            return "數據解析失败"
        case .NoRepresentor:
            return "NoRepresentor."
        case .NotSuccessfulHTTP:
            return "NotSuccessfulHTTP."
        case .NoData:
            return "NoData."
        case .CouldNotMakeObjectError:
            return "CouldNotMakeObjectError."
        case .InvalidAccess:
            return "Invalid access."
        case let .BizError(resultCode: resultCode, resultMsg: resultMsg):
            return "錯誤碼: \(resultCode), 錯誤信息: \(resultMsg)"
        }
    }
}

extension Response {
    func mapObject<T: Mappable>(_: T.Type, context: MapContext? = nil) throws -> T {
        guard let object = Mapper<T>(context: context).map(JSONObject: try mapJSON()) else {
            throw MoyaError.jsonMapping(self)
        }
        return object
    }
    
    func mapArray<T: Mappable>(_: T.Type, context: MapContext? = nil) throws -> [T] {
        guard let array = try mapJSON() as? [[String: Any]] else {
            throw MoyaError.jsonMapping(self)
        }
        return Mapper<T>(context: context).mapArray(JSONArray: array)
    }
}

extension Observable {
    func mapObject<T: BaseMappable>(type _: T.Type) -> Observable<T> {
        return map { response in
            // if response is a dictionary, then use ObjectMapper to map the dictionary
            // if not throw an error
            guard let dict = response as? [String: Any] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            
//            print("dict = \(dict)")
            
            return Mapper<T>().map(JSON: dict)!
        }
    }
    
    func mapArray<T: BaseMappable>(type _: T.Type) -> Observable<[T]> {
        return map { response in
            // if response is an array of dictionaries, then use ObjectMapper to map the dictionary
            // if not, throw an error
            guard let array = response as? [[String: Any]] else {
                throw RxSwiftMoyaError.ParseJSONError
            }
            return Mapper<T>().mapArray(JSONArray: array)
        }
    }
}
