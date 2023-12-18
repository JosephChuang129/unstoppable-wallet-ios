import UIKit
import ThemeKit
import ComponentKit

class CountryListCell: BaseSelectableThemeCell {
    private static let padding: CGFloat = .margin12
    private static let font: UIFont = .systemFont(ofSize: 16, weight: .medium)

    // MARK: ViewModel
    var viewModel: CountryListCellViewModelType?
    
    private lazy var nameLabel = UILabel().then {
        $0.font = CountryListCell.font
        $0.numberOfLines = 0
        $0.textColor = .themeLeah
    }

    private lazy var countryImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stackView = CommonHStackView(arrangedSubviews: [countryImageView, nameLabel], spacing: 10).then {
            $0.alignment = .center
        }
        
        wrapperView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(CountryListCell.padding)
        }
        
        countryImageView.snp.makeConstraints {
            $0.width.equalTo(38)
            $0.height.equalTo(26)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
      super.prepareForReuse()
        countryImageView.kf.cancelDownloadTask()
    }
    
    var title: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }

}


extension CountryListCell: CellConfigurable {
    func bind(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? CountryListCellViewModelType else { return }
        self.viewModel = viewModel
        
        let country = viewModel.outputs.country
        nameLabel.text = country.name
        countryImageView.kf.setImage(with: URL(string: country.flagUrl ?? ""), placeholder: UIImage(), options: [.transition(.fade(0.4))])
    }
}
