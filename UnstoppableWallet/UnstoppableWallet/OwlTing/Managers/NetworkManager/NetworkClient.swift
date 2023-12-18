//
//  NetworkClient.swift
//

import Foundation
import Moya

let baseDomainSSO = "https://auth-dev.owlting.com"
let baseDomainWallet = "https://wallet-admin-dev.owlting.com"

var walletApiUrl: String {
    (Bundle.main.object(forInfoDictionaryKey: "WalletApiUrl") as? String) ?? ""
}

let timeoutInterval = 30

// MARK: - set request timeout

let requestTimeoutClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<NetworkClient>.RequestResultClosure) in
    
    guard var request = try? endpoint.urlRequest() else { return }
    request.timeoutInterval = TimeInterval(timeoutInterval)
    done(.success(request))
}

let networkClientProvider = MoyaProvider<NetworkClient>(requestClosure: requestTimeoutClosure)

enum NetworkClient {
    
    case samplePost(parameter: [String: Any])
    case sampleGet(id: Int, parameter: [String: Any])
    
    // MARK: SSO
    case fetchUserSecret(parameter: [String: Any])
    case ssoPasswordForgot(parameter: [String: Any])
    
    // MARK: Owlting Wallet
    case otWalletLogin(parameter: [String: Any])
    case otWalletLogout
    case otWalletRegister(parameter: [String: Any])
    case otWalletSync(parameter: [String: Any])
    case otWalletTokenRefresh(parameter: [String: Any])
    case amlCountry(parameter: [String: Any])
    case amlRegister(parameter: [String: Any])
    case amlChainBinding(parameter: [String: Any])
    case amlMeta(parameter: [String: Any])
    case passwordForgot(parameter: [String: Any])
    case authTerminate
    case otCustomerProfile(uuid: String, parameter: [String: Any])
}

extension NetworkClient: TargetType {
    var baseURL: URL {
        switch self {
        case
                .fetchUserSecret,
                .ssoPasswordForgot:
            
            return URL(string: baseDomainSSO)!
            
        default:
            return URL(string: walletApiUrl)!
        }
    }
    
    public var path: String {
        switch self {
        case .samplePost(parameter: _):
            return ""
        case .sampleGet(let id, parameter: _):
            return "\(id)"
            
        case .fetchUserSecret(parameter: _):
            return "/api/project/\(OwltingSSOConstants.walletProjectID)/token"
        case .ssoPasswordForgot(parameter: _):
            return "/api/project/\(OwltingSSOConstants.walletProjectID)/passwordForgot"
            
        case .otWalletLogin(parameter: _):
            return "/api/external/auth/login"
        case .otWalletLogout:
            return "/api/external/auth/logout"
        case .otWalletRegister(parameter: _):
            return "/api/external/auth/register"
        case .otWalletSync(parameter: _):
            return "/api/external/customer/wallet/create"
        case .otWalletTokenRefresh(parameter: _):
            return "/api/external/auth/refresh"
        case .amlCountry(parameter: _):
            return "/api/external/customer/aml/country"
        case .amlRegister(parameter: _):
            return "/api/external/customer/aml/register"
        case .amlChainBinding(parameter: _):
            return "/api/external/customer/aml/chain/binding"
        case .amlMeta(parameter: _):
            return "/api/external/customer/aml/meta"
        case .passwordForgot:
            return "/api/external/auth/passwordForget"
        case .authTerminate:
            return "/api/external/auth/terminate"
        case .otCustomerProfile(let uuid, parameter: _):
            return "/api/external/customer/\(uuid)/profile"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case
                .fetchUserSecret,
                .ssoPasswordForgot,
                .otWalletLogin,
                .otWalletSync,
                .otWalletLogout,
                .otWalletRegister,
                .otWalletTokenRefresh,
                .amlRegister,
                .amlChainBinding,
                .passwordForgot,
                .authTerminate,
                .otCustomerProfile:
            
            return .post
            
            //        case
            //            :
            //            return .delete
            
            //        case : return .patch
            //        case
            //            return .put
            
        default: return .get
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        //        return URLEncoding.default
        return JSONEncoding.default
    }
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        switch self {
        case
            let .fetchUserSecret(parameter: parameter),
            let .ssoPasswordForgot(parameter: parameter),
            let .otWalletLogin(parameter: parameter),
            let .otWalletSync(parameter: parameter),
            let .otWalletTokenRefresh(parameter: parameter),
            let .otWalletRegister(parameter: parameter),
            let .amlRegister(parameter: parameter),
            let .amlChainBinding(parameter: parameter),
            let .passwordForgot(parameter: parameter),
            let .otCustomerProfile(uuid: _, parameter: parameter):
            
            return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
            
        case
            let .sampleGet(_, parameter: parameter),
            let .amlCountry(parameter: parameter),
            let .amlMeta(parameter: parameter):
            
            return .requestParameters(parameters: parameter, encoding: URLEncoding.default)
            
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        
        //        var headerToken: String = ""
        //        var headerTokenType: String = ""
        
        var httpHeaders = [
            HttpHeaders.headerKeyContentType : HttpHeaders.headerApplicationValue,
            "device" : "iOS"
        ]
        
        //        httpHeaders[HttpHeaders.headerKeyAuthorization] = "\(HttpHeaders.headerValueAuthorization) \(App.shared.accountManager.otWalletToken?.access ?? "")"
        
        switch self {
        case
                .otWalletTokenRefresh:
            
            httpHeaders[HttpHeaders.headerKeyAuthorization] = "\(HttpHeaders.headerValueAuthorization) \(App.shared.accountManager.otWalletToken?.refresh ?? "")"
            
        default:
            
            httpHeaders[HttpHeaders.headerKeyAuthorization] = "\(HttpHeaders.headerValueAuthorization) \(App.shared.accountManager.otWalletToken?.access ?? "")"
        }
//        print("httpHeaders = \(httpHeaders)")
        
        return httpHeaders
    }
}

// MARK: - Helpers

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

private let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
    return (FileSystem.downloadDirectory.appendingPathComponent(response.suggestedFilename!), [.removePreviousFile, .createIntermediateDirectories])
}

let DefaultDownloadDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

class FileSystem {
    static let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
    static let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    
    static let downloadDirectory: URL = {
        let directory: URL = FileSystem.documentsDirectory.appendingPathComponent("/FileDownload/")
        return directory
    }()
    
}

struct HttpHeaders {
    static let headerKeyAuthorization = "Authorization"
    static let headerValueAuthorization = "Bearer"
    static let headerKeyDevice = "Device-Type"
    static let headerValueDevice = "apple"
    static let headerKeyAccept = "Accept"
    static let headerApplicationValue = "application/json"
    static let headerKeyContentType = "Content-Type"
    static let headerKeySSOAuthorization = "SSO-ACCESSTOKEN"
}

struct OwltingSSOConstants {
    static let walletProjectID = "ff609ad8fa50b26d8fc7a95a2e6a86cd"
}
