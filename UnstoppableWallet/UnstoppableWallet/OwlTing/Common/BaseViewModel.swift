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
    
    let successRelay = PublishRelay<()>()
    let loadingRelay = PublishRelay<(Bool)>()
    let errorRelay = PublishRelay<()>()
    let errorHandlerRelay = PublishRelay<(ErrorResult)>()
    
    let showLoginRelay = PublishRelay<()>()
}

extension BaseViewModel {
    
    var loadingSignal: Signal<(Bool)> {
        loadingRelay.asSignal()
    }
    
    var successSignal: Signal<()> {
        successRelay.asSignal()
    }
    
    var errorSignal: Signal<()> {
        errorRelay.asSignal()
    }
    
    var errorHandlerSignal: Signal<(ErrorResult)> {
        errorHandlerRelay.asSignal()
    }
    
    var showLoginSignal: Signal<()> {
        showLoginRelay.asSignal()
    }
}
