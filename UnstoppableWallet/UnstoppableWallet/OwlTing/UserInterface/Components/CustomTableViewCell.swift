import UIKit
import RxSwift
import RxCocoa

class Primary2ButtonCell: UITableViewCell {
    private static let verticalPadding: CGFloat = .margin16
    static let height: CGFloat = Primary2Button.height + 2 * verticalPadding

    private let button = Primary2Button().then {
        $0.setTitle("binding_form.send_button".localized, for: .normal)
    }

    var onTap: (() -> ())?

    // MARK: ViewModel
    var viewModel: Primary2ButtonCellViewModelType?
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(button)
        button.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(CGFloat.margin16)
        }

        button.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
        button.set(style: .yellow)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func onTapButton() {
        onTap?()
    }

    var title: String? {
        get { button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }

    var isEnabled: Bool {
        get { button.isEnabled }
        set { button.isEnabled = newValue }
    }

    func set(style: Primary2Button.Style) {
        button.set(style: style)
    }

}

extension Primary2ButtonCell: CellConfigurable {
    func bind(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? Primary2ButtonCellViewModelType else { return }
        self.viewModel = viewModel
        
        isEnabled = viewModel.outputs.isEnabled
        subscribeToViewModel()
    }
    
    func subscribeToViewModel() {
        
        guard let viewModel = viewModel else { return }
        subscribe(disposeBag, viewModel.outputs.isEnableSignal) { [weak self] isEnabled in
            self?.isEnabled = isEnabled
        }
    }
}


import Foundation

protocol Primary2ButtonCellViewModelInput {}
protocol Primary2ButtonCellViewModelOutput: AnyObject {
    var cellPressed: ((IndexPath) -> Void)? { get set }
    var isEnabled: Bool { get }
    var isEnableSignal: Signal<Bool> { get }
}
protocol Primary2ButtonCellViewModelType {
    var inputs: Primary2ButtonCellViewModelInput { get }
    var outputs: Primary2ButtonCellViewModelOutput { get }
}

class Primary2ButtonCellViewModel: RowViewModel, Primary2ButtonCellViewModelType, Primary2ButtonCellViewModelInput, Primary2ButtonCellViewModelOutput, ViewModelPressible {
    
    // MARK: Input & Output
    var inputs: Primary2ButtonCellViewModelInput { return self }
    var outputs: Primary2ButtonCellViewModelOutput { return self }
    
    var isEnabled: Bool = false { didSet { isEnableRelay.accept(isEnabled) }}
    var cellPressed: ((IndexPath) -> Void)?
    
    private let isEnableRelay = PublishRelay<Bool>()
}

extension Primary2ButtonCellViewModel {

    var isEnableSignal: Signal<Bool> {
        isEnableRelay.asSignal()
    }
}
