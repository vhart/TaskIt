import UIKit
import RxSwift

class SprintSetUpIndicatorView: UIView {

    var onSetUpButtonTapped:(() -> Void)?
    var onFinishButtonTapped:(() -> Void)?
    private(set) var viewModel = ViewModel()
    private let disposeBag = DisposeBag()

    private var setUpButtonAnimatableConstraints = AnimationConstraints()
    private var finishButtonAnimationConstraints = AnimationConstraints()

    lazy var actionsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear

        return view
    }()

    lazy var setUpButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bluejay
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)

        button.layer.cornerRadius = 5

        return button
    }()

    lazy var finishButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .spring
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0, weight: .bold)

        button.layer.cornerRadius = 5

        return button
    }()

    init() {
        super.init(frame: CGRect.zero)
        layoutViews()
        addButtonActions()

        viewModel.title
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (title) in
                self?.setUpButton.setTitle(title, for: .normal)
        }.disposed(by: disposeBag)

        viewModel.alpha
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] (value) in
                self?.alpha = CGFloat(value)
            }.disposed(by: disposeBag)

        viewModel.actionStyle
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeNext { [weak self] style in
                self?.layoutActions(withStyle: style)
        }.disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func addButtonActions() {
        setUpButton.addTarget(self,
                              action: #selector(didTapSetUpButton(sender:)),
                              for: .touchUpInside)
        finishButton.addTarget(self,
                               action: #selector(didTapFinishButton(sender:)),
                               for: .touchUpInside)
    }

    @objc private func didTapSetUpButton(sender: UIButton) {
        onSetUpButtonTapped?()
    }

    @objc private func didTapFinishButton(sender: UIButton) {
        onFinishButtonTapped?()
    }

    private func layoutViews() {
        addSubview(actionsContainer)
        actionsContainer.addSubview(setUpButton)
        actionsContainer.addSubview(finishButton)

        NSLayoutConstraint.activate([
            actionsContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            actionsContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])

        let setUpButtonHeight = setUpButton.heightAnchor.constraint(equalTo: self.heightAnchor,
                                                                    multiplier: 0.2)

        let finishButtonTop = finishButton.topAnchor.constraint(equalTo: setUpButton.bottomAnchor,
                                                                constant: 8)
        let finishButtonHeight = finishButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.2)

        NSLayoutConstraint.activate([
            setUpButton.topAnchor.constraint(equalTo: actionsContainer.topAnchor),
            setUpButtonHeight,
            setUpButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            setUpButton.leadingAnchor.constraint(equalTo: actionsContainer.leadingAnchor),
            setUpButton.trailingAnchor.constraint(equalTo: actionsContainer.trailingAnchor),
            finishButtonTop,
            finishButtonHeight,
            finishButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            finishButton.bottomAnchor.constraint(equalTo: actionsContainer.bottomAnchor),
            finishButton.leadingAnchor.constraint(equalTo: actionsContainer.leadingAnchor),
            finishButton.trailingAnchor.constraint(equalTo: actionsContainer.trailingAnchor),
            ])

        setUpButtonAnimatableConstraints[.height] = setUpButtonHeight

        finishButtonAnimationConstraints[.top] = finishButtonTop
        finishButtonAnimationConstraints[.height] = finishButtonHeight

        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 5
        backgroundColor = UIColor.fog.withAlphaComponent(0.7)
    }

    private func layoutActions(withStyle style: SprintOverlayActions) {
        guard let setUpHeight = setUpButtonAnimatableConstraints[.height],
            let finishHeight = finishButtonAnimationConstraints[.height],
            let finishTop = finishButtonAnimationConstraints[.top]
            else { fatalError("invalid constraints")}

        var setUpAlpha: CGFloat = 0
        var finishAlpha: CGFloat = 0

        switch style {
        case _ where style.contains(.setUpAndFinish):
            if setUpHeight.multiplier != 0.2 {
                let newHeight = NSLayoutConstraint.changeMultiplier(setUpHeight, multiplier: 0.2)
                setUpButtonAnimatableConstraints[.height] = newHeight
                setUpAlpha = 1
            }

            if finishHeight.multiplier != 0.2 {
                let newHeight = NSLayoutConstraint.changeMultiplier(finishHeight, multiplier: 0.2)
                finishButtonAnimationConstraints[.height] = newHeight
                finishAlpha = 1
            }

            finishTop.constant = 8
        case _ where style.contains(.setUp):
            if setUpHeight.multiplier != 0.2 {
                let newHeight = NSLayoutConstraint.changeMultiplier(setUpHeight, multiplier: 0.2)
                setUpButtonAnimatableConstraints[.height] = newHeight
                setUpAlpha = 1
            }

            if finishHeight.multiplier != CGFloat.leastNormalMagnitude {
                let newHeight = NSLayoutConstraint.changeMultiplier(finishHeight, multiplier: CGFloat.leastNormalMagnitude)
                finishButtonAnimationConstraints[.height] = newHeight
                finishAlpha = 0
            }

            finishTop.constant = 0
        case _ where style.contains(.finish):
            if setUpHeight.multiplier != CGFloat.leastNormalMagnitude {
                let newHeight = NSLayoutConstraint.changeMultiplier(setUpHeight, multiplier: CGFloat.leastNormalMagnitude)
                setUpButtonAnimatableConstraints[.height] = newHeight
                setUpAlpha = 0
            }

            if finishHeight.multiplier != 0.2 {
                let newHeight = NSLayoutConstraint.changeMultiplier(finishHeight, multiplier: 0.2)
                finishButtonAnimationConstraints[.height] = newHeight
                finishAlpha = 1
            }

            finishTop.constant = 0
        default: fatalError("Unexpected style")
        }

        UIView.animate(withDuration: 0.3) {
            self.setUpButton.alpha = setUpAlpha
            self.finishButton.alpha = finishAlpha
            self.layoutIfNeeded()
        }
    }
}

extension SprintSetUpIndicatorView {

    struct SprintOverlayActions: OptionSet {
        let rawValue: Int

        static let setUp = SprintOverlayActions(rawValue: 1 << 0)
        static let finish = SprintOverlayActions(rawValue: 1 << 1)
        static let setUpAndFinish: SprintOverlayActions = [.setUp, .finish]

        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    class ViewModel {
        let title = Variable<String>("")
        let alpha = Variable<Float>(0.0)
        let actionStyle = PublishSubject<SprintOverlayActions>()

        func setTitle(_ title: String) {
            self.title.value = title
        }

        func setHidden(_ isHidden: Bool) {
            alpha.value = isHidden ? 0.0 : 1.0
        }

        func layout(style: SprintOverlayActions) {
            actionStyle.onNext(style)
        }
    }
}
