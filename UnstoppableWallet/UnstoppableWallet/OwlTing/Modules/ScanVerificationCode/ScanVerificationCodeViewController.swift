import UIKit
import ThemeKit
import RxSwift
import ComponentKit
import ScanQrKit

class ScanVerificationCodeViewController: ThemeViewController {
    weak var delegate: ScanVerificationCodeDelegate?
    
    private let viewModel: ScanVerificationCodeViewModel
    private let scanView: ScanQrView
    private let cancelButton = PrimaryButton()
    let disposeBag = DisposeBag()

    var onUserDismissed: (() -> ())?

    init(viewModel: ScanVerificationCodeViewModel, delegate: ScanVerificationCodeDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate

        let bottomInset: CGFloat = .margin24 + PrimaryButton.height
        scanView = ScanQrView(bottomInset: bottomInset)
        
        super.init()
        
        hidesBottomBarWhenPushed = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        bindViewModel()
        viewModel.start()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scanView.startCaptureSession()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        scanView.stop()
    }

    @objc func onCancel() {
        onUserDismissed?()
        dismiss(animated: true)
    }

    func startCaptureSession() {
        scanView.startCaptureSession()
    }

    func onScan(string: String) {
        delegate?.didScan(string: string)
        onUserDismissed?()
        dismiss(animated: true)
    }

}

extension ScanVerificationCodeViewController {
    private func viewSetup() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close_3_24"), style: .plain, target: self, action: #selector(onCancel))
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundColor = .clear
        standardAppearance.shadowImage = UIImage()
        standardAppearance.backgroundImage = UIImage()
        navigationController?.navigationBar.standardAppearance = standardAppearance
        
        view.addSubview(scanView)
        scanView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        scanView.delegate = self

//        view.addSubview(cancelButton)
//        cancelButton.snp.makeConstraints { maker in
//            maker.leading.trailing.equalToSuperview().inset(CGFloat.margin24)
//            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(CGFloat.margin24)
//        }

//        cancelButton.set(style: .gray)
//        cancelButton.setTitle("button.cancel".localized, for: .normal)
//        cancelButton.setTitle("手動輸入", for: .normal)

        scanView.start()
    }
    
    private func bindViewModel() {
        
        cancelButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.pushViewController(ManualInputVerificationCodeModule.viewController(), animated: true)
        }).disposed(by: disposeBag)
    }
}

extension ScanVerificationCodeViewController: IScanQrCodeDelegate {

    func didScan(string: String) {
        scanView.stop()
        onScan(string: string)
    }

}
