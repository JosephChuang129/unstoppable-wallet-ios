import UIKit

class WaringStackView: CommonHStackView {

    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    }
    
    let warningImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "warning_2_24")
    }
    
    init() {
        
        warningImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        warningImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        super.init(arrangedSubviews: [warningImageView, titleLabel], spacing: 4)
        
        alignment = .top
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

