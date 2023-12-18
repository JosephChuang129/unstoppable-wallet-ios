//
//  ViewModel.swift
//

import Foundation
import RxCocoa
import RxRelay

class BaseViewModel: NSObject {
    
    var isLoading: ((Bool) -> Void)?
    var onErrorHandling: ((ErrorResult) -> Void)?
    var updateHandler: (() -> Void)?
    
    let successRelay = PublishRelay<String>()
    let loadingRelay = PublishRelay<(Bool)>()
    let errorRelay = PublishRelay<String>()
    let errorHandlerRelay = PublishRelay<(ErrorResult)>()
    
    let showLoginRelay = PublishRelay<()>()
}

extension BaseViewModel {
    
    var loadingSignal: Signal<(Bool)> {
        loadingRelay.asSignal()
    }
    
    var successSignal: Signal<String> {
        successRelay.asSignal()
    }
    
    var errorSignal: Signal<String> {
        errorRelay.asSignal()
    }
    
    var errorHandlerSignal: Signal<(ErrorResult)> {
        errorHandlerRelay.asSignal()
    }
    
    var showLoginSignal: Signal<()> {
        showLoginRelay.asSignal()
    }
}
