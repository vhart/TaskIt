import UIKit

@IBDesignable public class CenterExpandingView: UIView {
    private struct ExpansionConstraints {
        let isExpanded: Bool

        let leftLead: NSLayoutConstraint
        let rightTrailing: NSLayoutConstraint
    }

    private var expansionConstraints: ExpansionConstraints!

    @IBInspectable var leftViewBackgroundColor: UIColor {
        get {
            return leftViewColor
        } set {
            leftViewColor = newValue
        }
    }

    @IBInspectable var rightViewBackgroundColor: UIColor {
        get {
            return rightViewColor
        } set {
            rightViewColor = newValue
        }
    }

    var leftViewColor : UIColor = .black {
        didSet {
            leftView.backgroundColor = leftViewColor
        }
    }

    var rightViewColor: UIColor = .black {
        didSet {
            rightView.backgroundColor = rightViewColor
        }
    }

    lazy var leftView: UIView = {
        let lv = UIView()
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.backgroundColor = leftViewColor
        return lv
    }()

    lazy var rightView: UIView = {
        let rv = UIView()
        rv.translatesAutoresizingMaskIntoConstraints = false
        rv.backgroundColor = rightViewColor
        return rv
    }()

    func open() {
        updateExpansion(shouldExpand: true)
    }

    func close() {
        updateExpansion(shouldExpand: false)
    }

    func updateExpansion(shouldExpand: Bool, animated: Bool = true) {
        guard expansionConstraints.isExpanded != shouldExpand else { return }

        NSLayoutConstraint.deactivate([
            expansionConstraints.leftLead,
            expansionConstraints.rightTrailing
            ])

        self.expansionConstraints = getExpansionConstraints(expanded: shouldExpand)

        NSLayoutConstraint.activate([
            expansionConstraints.leftLead,
            expansionConstraints.rightTrailing
            ])

        if animated {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }

    init() {
        super.init(frame: .zero)
        layoutViews()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        layoutViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutViews()
    }

    private func layoutViews() {
        self.addSubview(leftView)
        self.addSubview(rightView)

        let leftTrailing = NSLayoutConstraint(item: leftView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0)

        let expansionConstraints = getExpansionConstraints(expanded: false)

        NSLayoutConstraint.activate([
            leftTrailing,
            rightView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            leftView.topAnchor.constraint(equalTo: self.topAnchor),
            rightView.topAnchor.constraint(equalTo: self.topAnchor),
            leftView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rightView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            expansionConstraints.leftLead,
            expansionConstraints.rightTrailing
            ])

        self.expansionConstraints = expansionConstraints
    }

    private func getExpansionConstraints(expanded: Bool) -> ExpansionConstraints {
        var left: NSLayoutConstraint
        var right: NSLayoutConstraint

        if expanded {
            left = leftView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            right = rightView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        } else {
            left = leftView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor)
            right = rightView.trailingAnchor.constraint(equalTo: rightView.leadingAnchor)
        }

        return ExpansionConstraints(isExpanded: expanded,
                                    leftLead: left,
                                    rightTrailing: right)
    }
}

