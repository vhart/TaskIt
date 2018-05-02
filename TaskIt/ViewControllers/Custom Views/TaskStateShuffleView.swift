import UIKit

protocol ShuffleViewDelegate: class {
    func shuffleViewWillExpand(_ shuffleView: ShuffleView)
    func shuffleViewWillCollapse(_ shuffleView: ShuffleView)
}

class ShuffleView: UIView {

    enum Selected {
        case left
        case right
        case middle
    }

    private var collapsed = true
    private var ignoreTaps = false
    private var leftMidConstraint: NSLayoutConstraint!
    private var rightMidConstraint: NSLayoutConstraint!
    public private(set) var selected: Selected
    weak var delegate: ShuffleViewDelegate?

    var onSelection: ((Selected) -> Void)?

    lazy var middleButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .ocean
        b.translatesAutoresizingMaskIntoConstraints = false
        b.imageView?.contentMode = .scaleAspectFit
        let image = UIImage(named: "more")?.withRenderingMode(.alwaysTemplate)
        b.imageView?.tintColor = .white
        b.setImage(image, for: .normal)
        b.setImage(image, for: .highlighted)
        b.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        return b
    }()

    lazy var leftButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .tangerine
        b.translatesAutoresizingMaskIntoConstraints = false
        b.imageView?.contentMode = .scaleAspectFit
        let image = UIImage(named: "idle")?.withRenderingMode(.alwaysTemplate)
        b.imageView?.tintColor = .white
        b.setImage(image, for: .normal)
        b.setImage(image, for: .highlighted)
        b.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return b
    }()

    lazy var rightButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .spring
        b.translatesAutoresizingMaskIntoConstraints = false
        b.imageView?.contentMode = .scaleAspectFit
        let image = #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
        b.imageView?.tintColor = .white
        b.setImage(image, for: .normal)
        b.setImage(image, for: .highlighted)
        b.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return b
    }()

    convenience init(state: TaskState) {
        let selected: Selected
        switch state {
        case .unstarted: selected = .left
        case .inProgress: selected = .middle
        case .finished: selected = .right
        }

        self.init(selected: selected)
    }

    init(selected: Selected){
        self.selected = selected
        super.init(frame: CGRect.zero)
        setUpViews()
        leftButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        middleButton.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        let radius = frame.height * 0.55 / 2
        middleButton.layer.cornerRadius = radius
        rightButton.layer.cornerRadius = radius
        leftButton.layer.cornerRadius = radius
    }

    private func setUpViews() {
        self.addSubview(middleButton)
        self.addSubview(leftButton)
        self.addSubview(rightButton)
        bringSelectedToFront()

        leftMidConstraint = leftButton.trailingAnchor.constraint(equalTo: middleButton.trailingAnchor)
        rightMidConstraint = rightButton.leadingAnchor.constraint(equalTo: middleButton.leadingAnchor)

        NSLayoutConstraint.activate([
            middleButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            middleButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            middleButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.55),
            middleButton.widthAnchor.constraint(equalTo: middleButton.heightAnchor, multiplier: 1),
            leftMidConstraint,
            leftButton.centerYAnchor.constraint(equalTo: middleButton.centerYAnchor),
            leftButton.widthAnchor.constraint(equalTo: middleButton.widthAnchor, multiplier: 1),
            leftButton.heightAnchor.constraint(equalTo: middleButton.heightAnchor, multiplier: 1),
            rightMidConstraint,
            rightButton.centerYAnchor.constraint(equalTo: middleButton.centerYAnchor),
            rightButton.widthAnchor.constraint(equalTo: middleButton.widthAnchor, multiplier: 1),
            rightButton.heightAnchor.constraint(equalTo: middleButton.heightAnchor, multiplier: 1),
            ])

        applyCollapseTransforms()
    }

    private func bringSelectedToFront() {
        switch selected {
        case .left: bringSubview(toFront: leftButton)
        case .right: bringSubview(toFront: rightButton)
        case .middle: bringSubview(toFront: middleButton)
        }
    }

    private func affineTransform(for selection: Selected) -> CGAffineTransform {
        return selection == selected ? CGAffineTransform(scaleX: 1.2, y: 1.2) : CGAffineTransform(scaleX: 1.05, y: 1.05)
    }

    private func collapseAffineTransform(for selection: Selected) -> CGAffineTransform {
        return selection == selected ? CGAffineTransform(scaleX: 1.01, y: 1.01) : .identity
    }

    @objc private func buttonClicked(sender: UIButton) {
        guard !ignoreTaps else { return }
        ignoreTaps = true

        guard !collapsed else { expand(); return }

        switch sender {
        case leftButton: selected = .left
        case rightButton: selected = .right
        case middleButton: selected = .middle
        default: break
        }

        onSelection?(selected)

        UIView.animate(withDuration: 0.1, animations: {
            self.applyExpansionTransforms()
        }, completion: { _ in self.collapse() })
    }

    private func expand() {
        NSLayoutConstraint.deactivate([rightMidConstraint, leftMidConstraint])

        let offSet = middleButton.frame.width / 2

        rightMidConstraint = rightButton.leadingAnchor.constraint(equalTo: middleButton.trailingAnchor, constant: offSet)

        leftMidConstraint = leftButton.trailingAnchor.constraint(equalTo: middleButton.leadingAnchor, constant: -1 * offSet)

        NSLayoutConstraint.activate([self.rightMidConstraint, self.leftMidConstraint])

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 20, options: .curveLinear, animations: {

            self.superview?.layoutIfNeeded()
            self.applyExpansionTransforms()
            self.delegate?.shuffleViewWillExpand(self)
        }, completion: { _ in
            self.ignoreTaps = false
            self.collapsed = false
        })
    }

    private func collapse() {
        NSLayoutConstraint.deactivate([rightMidConstraint, leftMidConstraint])

        rightMidConstraint = rightButton.trailingAnchor.constraint(equalTo: middleButton.trailingAnchor)

        leftMidConstraint = leftButton.leadingAnchor.constraint(equalTo: middleButton.leadingAnchor)

        bringSelectedToFront()

        NSLayoutConstraint.activate([rightMidConstraint, leftMidConstraint])

        UIView.animate(withDuration: 0.3, animations: {
            self.superview?.layoutIfNeeded()
            self.applyCollapseTransforms()
            self.delegate?.shuffleViewWillCollapse(self)
        }, completion: { (_) in
            self.ignoreTaps = false
            self.collapsed = true
        })
    }

    private func applyExpansionTransforms() {
        rightButton.transform = affineTransform(for: .right)
        leftButton.transform = affineTransform(for: .left)
        middleButton.transform = affineTransform(for: .middle)
    }

    private func applyCollapseTransforms() {
        rightButton.transform = collapseAffineTransform(for: .right)
        leftButton.transform = collapseAffineTransform(for: .left)
        middleButton.transform = collapseAffineTransform(for: .middle)
    }
}
