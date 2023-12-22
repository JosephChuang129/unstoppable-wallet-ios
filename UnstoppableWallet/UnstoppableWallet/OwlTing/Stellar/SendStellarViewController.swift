
import ThemeKit
import SnapKit
import SectionsTableView
import RxSwift
import RxCocoa
import TronKit
import UIKit

class SendStellarViewController: ThemeViewController {
    private let stellarKitWrapper: StellarKitWrapper
    private let viewModel: SendStellarViewModel
    private let disposeBag = DisposeBag()

    private let iconImageView = UIImageView()
    private let tableView = SectionsTableView(style: .grouped)

    private let availableBalanceCell: SendAvailableBalanceCell

    private let amountCell: AmountInputCell
    private let amountCautionCell = FormCautionCell()

    private let recipientCell: RecipientAddressInputCell
    private let recipientCautionCell: RecipientAddressCautionCell

    private let buttonCell = PrimaryButtonCell()

    private var isLoaded = false
    private var keyboardShown = false

    init(stellarKitWrapper: StellarKitWrapper, viewModel: SendStellarViewModel, availableBalanceViewModel: ISendAvailableBalanceViewModel, amountViewModel: AmountInputViewModel, recipientViewModel: RecipientAddressViewModel) {
        self.stellarKitWrapper = stellarKitWrapper
        self.viewModel = viewModel

        availableBalanceCell = SendAvailableBalanceCell(viewModel: availableBalanceViewModel)

        amountCell = AmountInputCell(viewModel: amountViewModel)

        recipientCell = RecipientAddressInputCell(viewModel: recipientViewModel)
        recipientCautionCell = RecipientAddressCautionCell(viewModel: recipientViewModel)

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        if (navigationController?.viewControllers.count ?? 0) == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: iconImageView)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "button.cancel".localized, style: .plain, target: self, action: #selector(didTapCancel))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(CGFloat.iconSize24)
        }
        iconImageView.setImage(withUrlString: viewModel.token.coin.imageUrl, placeholder: UIImage(named: viewModel.token.placeholderImageName))

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.sectionDataSource = self

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        amountCautionCell.onChangeHeight = { [weak self] in self?.reloadTable() }

        recipientCell.onChangeHeight = { [weak self] in self?.reloadTable() }
        recipientCell.onOpenViewController = { [weak self] in self?.present($0, animated: true) }

        recipientCautionCell.onChangeHeight = { [weak self] in self?.reloadTable() }

        buttonCell.set(style: .yellow)
        buttonCell.title = "send.next_button".localized
        buttonCell.onTap = { [weak self] in
            self?.didTapProceed()
        }

        subscribe(disposeBag, viewModel.proceedEnableDriver) { [weak self] in self?.buttonCell.isEnabled = $0 }
        subscribe(disposeBag, viewModel.amountCautionDriver) { [weak self] caution in
            self?.amountCell.set(cautionType: caution?.type)
            self?.amountCautionCell.set(caution: caution)
        }
        subscribe(disposeBag, viewModel.addressCautionDriver) { [weak self] caution in
            self?.recipientCell.set(cautionType: caution?.type)
            self?.recipientCautionCell.set(caution: caution)
        }
        subscribe(disposeBag, viewModel.proceedSignal) { [weak self] in self?.openConfirm(sendData: $0) }
//        subscribe(disposeBag, viewModel.proceedSignal) { [weak self] in
//
//            guard let self = self else { return }
//            guard let viewController = SendStellarConfirmationModule.viewController(stellarKitWrapper: self.stellarKitWrapper) else {
//                return
//            }
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }

        tableView.buildSections()
        isLoaded = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !keyboardShown {
            keyboardShown = true
            _ = amountCell.becomeFirstResponder()
        }
    }

    @objc private func didTapProceed() {
        viewModel.didTapProceed()
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    private func reloadTable() {
        guard isLoaded else {
            return
        }

        UIView.animate(withDuration: 0.2) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    private func openConfirm(sendData: StellarSendData) {
        guard let viewController = SendStellarConfirmationModule.viewController(stellarKitWrapper: stellarKitWrapper, sendData: sendData, token: stellarKitWrapper.token) else {
            return
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension SendStellarViewController: SectionsDataSource {

    func buildSections() -> [SectionProtocol] {
        var sections = [
            Section(
                id: "available-balance",
                headerState: .margin(height: .margin12),
                rows: [
                    StaticRow(
                        cell: availableBalanceCell,
                        id: "available-balance",
                        height: availableBalanceCell.cellHeight
                    )
                ]
            ),
            Section(
                id: "amount",
                headerState: .margin(height: .margin16),
                rows: [
                    StaticRow(
                        cell: amountCell,
                        id: "amount-input",
                        height: amountCell.cellHeight
                    ),
                    StaticRow(
                        cell: amountCautionCell,
                        id: "amount-caution",
                        dynamicHeight: { [weak self] width in
                            self?.amountCautionCell.height(containerWidth: width) ?? 0
                        }
                    )
                ]
            )
        ]
        if viewModel.showAddress {
            sections.append(
                    Section(
                            id: "recipient",
                            headerState: .margin(height: .margin16),
                            rows: [
                                StaticRow(
                                        cell: recipientCell,
                                        id: "recipient-input",
                                        dynamicHeight: { [weak self] width in
                                            self?.recipientCell.height(containerWidth: width) ?? 0
                                        }
                                ),
                                StaticRow(
                                        cell: recipientCautionCell,
                                        id: "recipient-caution",
                                        dynamicHeight: { [weak self] width in
                                            self?.recipientCautionCell.height(containerWidth: width) ?? 0
                                        }
                                )
                            ]
                    )
            )
        }
        sections.append(
                Section(
                        id: "button",
                        footerState: .margin(height: .margin32),
                        rows: [
                            StaticRow(
                                    cell: buttonCell,
                                    id: "button",
                                    height: PrimaryButtonCell.height
                            )
                        ]
                )
        )
        return sections
    }

}

import RxSwift
import RxCocoa
import TronKit
import MarketKit

class SendStellarViewModel {
    private let service: SendStellarService
    private let disposeBag = DisposeBag()

    private let proceedEnabledRelay = BehaviorRelay<Bool>(value: false)
    private let amountCautionRelay = BehaviorRelay<Caution?>(value: nil)
    private let addressCautionRelay = BehaviorRelay<Caution?>(value: nil)
    private let proceedRelay = PublishRelay<StellarSendData>()
//    private let proceedRelay = PublishRelay<()>()

    init(service: SendStellarService) {
        self.service = service

        subscribe(disposeBag, service.stateObservable) { [weak self] in self?.sync(state: $0) }
        subscribe(disposeBag, service.amountCautionObservable) { [weak self] in self?.sync(amountCaution: $0) }
        subscribe(disposeBag, service.addressErrorObservable) { [weak self] in self?.sync(addressError: $0) }

        sync(state: service.state)
    }

    private func sync(state: SendStellarService.State) {
        if case .ready = state {
            proceedEnabledRelay.accept(true)
        } else {
            proceedEnabledRelay.accept(false)
        }
    }

    private func sync(amountCaution: (error: Error?, warning: SendStellarService.AmountWarning?)) {
        var caution: Caution? = nil

        if let error = amountCaution.error {
            caution = Caution(text: error.smartDescription, type: .error)
        } else if let warning = amountCaution.warning {
            switch warning {
                case .coinNeededForFee: caution = Caution(text: "send.amount_warning.coin_needed_for_fee".localized(service.sendToken.coin.code), type: .warning)
            }
        }

        amountCautionRelay.accept(caution)
    }

    private func sync(addressError: Error?) {
        var caution: Caution? = nil

        if let error = addressError {
            caution = Caution(text: error.smartDescription, type: .error)
        }

        addressCautionRelay.accept(caution)
    }

}

extension SendStellarViewModel {

    var title: String {
        switch service.mode {
        case .send: return "send.title".localized(token.coin.code)
        case .predefined: return "donate.title".localized(token.coin.code)
        }
    }

    var showAddress: Bool {
        switch service.mode {
        case .send: return true
        case .predefined: return false
        }
    }

    var proceedEnableDriver: Driver<Bool> {
        proceedEnabledRelay.asDriver()
    }

    var amountCautionDriver: Driver<Caution?> {
        amountCautionRelay.asDriver()
    }

    var addressCautionDriver: Driver<Caution?> {
        addressCautionRelay.asDriver()
    }

    var proceedSignal: Signal<StellarSendData> {
        proceedRelay.asSignal()
    }
//    var proceedSignal: Signal<()> {
//        proceedRelay.asSignal()
//    }

    var token: Token {
        service.sendToken
    }

    func didTapProceed() {
        
        guard case .ready(let sendData) = service.state else {
            return
        }

//        proceedRelay.accept(())
        proceedRelay.accept(sendData)
    }

}

extension SendStellarService.AmountError: LocalizedError {

    var errorDescription: String? {
        switch self {
            case .insufficientBalance: return "send.amount_error.balance".localized
            default: return "\(self)"
        }
    }

}

extension SendStellarService.AddressError: LocalizedError {

    var errorDescription: String? {
        switch self {
            case .ownAddress: return "send.address_error.own_address".localized
            default: return "\(self)"
        }
    }

}
