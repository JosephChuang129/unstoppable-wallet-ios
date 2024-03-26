
import FirebaseAnalytics
import FirebaseCore

enum AnalyticsEvent {
    case eventLaunch

    var name: String {
        switch self {
        case .eventLaunch: return "event_launch"
        }
    }
}

class AnalyticsManager: NSObject {
    
    override init() {
        
        super.init()
        
        print("\(type(of: self)) \(#function)")
        
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"), let options = FirebaseOptions.init(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
            
            sendAnalyticsEvent(name: AnalyticsEvent.eventLaunch.name)
        }
    }
    
    deinit {
        print("\(type(of: self)) \(#function)")
    }
    
    func sendAnalyticsEvent(name: String, parameters: [String : Any]? = nil) {
        
        Analytics.logEvent(name, parameters: parameters)
        print("sendAnalyticsEvent logEvent name = \(name)")
        print("sendAnalyticsEvent logEvent params = \(parameters)")
    }
}
