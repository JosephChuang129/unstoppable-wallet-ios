//
//  NetworkService.swift
//

import Foundation
import ObjectMapper
import RxSwift
import Moya
import RxMoya
import ComponentKit
import UIKit

enum TokenError : Error {
    case tokenExpired
}

class NetworkService {

    private let networkQueue = ConcurrentDispatchQueueScheduler.init(qos: .default)
    private let accountManager: AccountManager

    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    func requestResponseArray<T: BaseMappable>(networkClient: NetworkClient) -> Observable<[T]> {
        return networkClientProvider.rx.request(networkClient)
            .asObservable()
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapArray(type: T.self)
    }
    
    func request<T: BaseMappable>(networkClient: NetworkClient) -> Observable<T> {
//        print("baseURL = \(networkClient.baseURL)")
//        print("path = \(networkClient.path)")
//        print("task = \(networkClient.task)")

        return networkClientProvider.rx.request(networkClient)
            .asObservable()
            .retry(1)
            .subscribeOn(networkQueue)
            .observeOn(MainScheduler.instance)
            .map({ response in
                
                if response.statusCode == 401 {
                    throw TokenError.tokenExpired
                }
                return response
            })
            .retryWhen({ (error: Observable<TokenError>) in
                error.flatMap { error -> Observable<()> in
                    switch error {
                    case .tokenExpired:
                        return NetworkService.refreshTokenRequest().share(replay: 1, scope: .whileConnected)
                            .flatMap { [weak self] result -> Observable<()> in
                                switch result {
                                case let .success(response):

                                    self?.accountManager.otWalletToken = response.token
                                    
                                    return Observable.just("").asObservable().map { _ in return () }
                                    
                                case let .failure(error):
                                    
//                                    print("retryWhen error = \(error)")
                                    self?.accountManager.otAccountLogout()
                                    HudHelper.instance.hide()
                                    UIApplication.shared.windows.first { $0.isKeyWindow }?.set(newRootController: MainModule.instance())
                                    
                                    throw error
                                }
                                
                            }
                    }
                }
            })
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapObject(type: T.self)
    }
    
    private static func refreshTokenRequest() -> Observable<Result<OTWalletTokenRefreshResponse, Error>> {

        let parameter = OTWalletLoginRequest()
//        parameter.expire = 0.5*2*24*60
//        parameter.expire = 0.0166666667
        
        let result = networkClientProvider.rx.request(.otWalletTokenRefresh(parameter: parameter.toJSON()))
            .asObservable()
            .map({ response in

                if response.statusCode == 401 {
                    throw MoyaError.statusCode(response)
                }
                return response
            })
            .mapJSON()
            .mapObject(type: OTWalletTokenRefreshResponse.self)
            .map {
                Result.success($0)
            }
            .catchError { error in
                Observable.just(Result.failure(error))
            }
        return result
    }
}
