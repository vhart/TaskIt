import UIKit
import RxSwift

class SprintSetUpIndicatorView: UIView {

    var onButtonTapped:(() -> Void)?
    private(set) var viewModel = ViewModel()
    private let disposeBag = DisposeBag()

    lazy var setupButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bluejay
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)

        button.layer.cornerRadius = 5

        return button
    }()

    init() {
        super.init(frame: CGRect.zero)
        layoutViews()
        addButtonAction()

        viewModel.title
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (title) in
                self?.setupButton.setTitle(title, for: .normal)
        }.disposed(by: disposeBag)

        viewModel.alpha
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (value) in
                self?.alpha = CGFloat(value)
            }.disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func addButtonAction() {
        setupButton.addTarget(self,
                              action: #selector(didTapButton),
                              for: .touchUpInside)
    }

    private func layoutViews() {
        addSubview(setupButton)
        NSLayoutConstraint.activate([
            setupButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            setupButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            setupButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            setupButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.2)
            ])

        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 5
        backgroundColor = .fog
    }

    @objc private func didTapButton() {
        onButtonTapped?()
    }
}

extension SprintSetUpIndicatorView {
    class ViewModel {
        let title = Variable<String>("")
        let alpha = Variable<Float>(0.0)

        func setTitle(_ title: String) {
            self.title.value = title
        }

        func setHidden(_ isHidden: Bool) {
            alpha.value = isHidden ? 0.0 : 0.7
        }
    }
}
