
import Foundation
import Combine
import HsToolKit
import stellarsdk
import HsExtensions
import MarketKit

protocol IStellarSyncTimerDelegate: AnyObject {
    func didUpdate(state: StellarSyncTimer.State)
    func sync()
}

class StellarSyncTimer {
    weak var delegate: IStellarSyncTimerDelegate?
    
    private let reachabilityManager: ReachabilityManager
    private let syncInterval: TimeInterval
    private var cancellables = Set<AnyCancellable>()
    private var tasks = Set<AnyTask>()
    
    private var isStarted = false
    private var timer: Timer?
    
    private(set) var state: State = .notReady(error: StellarKit.SyncError.notStarted) {
        didSet {
            if state != oldValue {
                delegate?.didUpdate(state: state)
            }
        }
    }
    
    init(reachabilityManager: ReachabilityManager, syncInterval: TimeInterval) {
        self.reachabilityManager = reachabilityManager
        self.syncInterval = syncInterval
        
        reachabilityManager.$isReachable
            .sink { [weak self] reachable in
                self?.handleUpdate(reachable: reachable)
            }
            .store(in: &cancellables)
    }
    
    deinit {
        stop()
    }
    
    @objc func onFireTimer() {
        Task { [weak self] in
            self?.delegate?.sync()
        }.store(in: &tasks)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { [weak self] _ in
            self?.onFireTimer()
        }
        timer?.tolerance = 0.5
    }
    
    private func handleUpdate(reachable: Bool) {
        guard isStarted else {
            return
        }
        
        if reachable {
            state = .ready
            
            DispatchQueue.main.async { [weak self] in
                self?.startTimer()
            }
        } else {
            state = .notReady(error: StellarKit.SyncError.noNetworkConnection)
            timer?.invalidate()
        }
    }
    
}

extension StellarSyncTimer {
    
    func start() {
        isStarted = true
        
        handleUpdate(reachable: reachabilityManager.isReachable)
    }
    
    func stop() {
        isStarted = false
        
        cancellables = Set()
        tasks = Set()
        
        state = .notReady(error: StellarKit.SyncError.notStarted)
        timer?.invalidate()
    }
    
}

extension StellarSyncTimer {
    
    enum State: Equatable {
        case ready
        case notReady(error: Error)
        
        public static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.ready, .ready): return true
            case (.notReady(let lhsError), .notReady(let rhsError)): return "\(lhsError)" == "\(rhsError)"
            default: return false
            }
        }
        
    }
    
}




