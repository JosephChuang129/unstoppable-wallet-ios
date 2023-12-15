import UIKit
import SnapKit

class DatePickerPopupView: UIView {
    
    private var containerView: UIView!
    private var datePicker: UIDatePicker!
    private var okButton: UIButton!
    private var cancelButton: UIButton!
    private lazy var confirmButton = Primary2Button().then {
        $0.setTitle("button.ok".localized, for: .normal)
        $0.set(style: .yellow)
        $0.addTarget(self, action: #selector(onTapConfirm), for: .touchUpInside)
    }
    
    var delegate: (_ date: Date?) -> Void = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        addSubview(shadowView)
        shadowView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
//        shadowView.addGestureRecognizer(gestureRecognizer)
        
        // Frame view
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.themeClaude
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.center.equalTo(self)
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                $0.leading.trailing.lessThanOrEqualToSuperview().inset(20)
            }
        }
        
        // Date picker
        datePicker = UIDatePicker()
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.datePickerMode = .date
        containerView.addSubview(datePicker)
        datePicker.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(20)
            $0.bottom.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc func tapHandler(_ g: UITapGestureRecognizer) -> Void {
        disappearAndReturn(date: datePicker.date)
    }
    
    @objc func cancelPressed() {
        disappearAndReturn(date: nil)
    }
    
    @objc func okPressed() {
        disappearAndReturn(date: datePicker.date)
    }
    
    @objc private func onTapConfirm() {
        disappearAndReturn(date: datePicker.date)
    }
    
    private func disappearAndReturn(date: Date?) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.0
        } completion: { (_) in
            self.removeFromSuperview()
            self.delegate(date)
        }
    }
    
    static func show(date: Date?, maximumDate: Date? = nil, delegate: @escaping (_ date: Date?) -> Void) {
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        guard var viewController = keyWindow?.rootViewController else { return }
        while let presentedViewController = viewController.presentedViewController {
            viewController = presentedViewController
        }
        
        let popup = DatePickerPopupView(frame: viewController.view.bounds)
        popup.delegate = delegate
        popup.datePicker.date = date ?? Date()
        if let maximumDate = maximumDate {
            popup.datePicker.maximumDate = maximumDate
        }
        popup.alpha = 0.0
        viewController.view.addSubview(popup)
        
        UIView.animate(withDuration: 0.3) {
            popup.alpha = 1.0
        }
    }
}
