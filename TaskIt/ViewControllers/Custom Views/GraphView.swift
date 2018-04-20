import UIKit

class GradientView: UIView {
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer? { return layer as? CAGradientLayer }
}

class SprintGraphView: UIView {
    lazy var unstartedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Unstarted"
        label.font = .systemFont(ofSize: 15)

        return label
    }()

    lazy var inProgressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "In Progress"
        label.font = .systemFont(ofSize: 15)

        return label
    }()

    lazy var finishedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Finished"
        label.font = .systemFont(ofSize: 15)

        return label
    }()

    lazy var unstartedBar: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.red
        view.gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer?.colors = CGColor.reds

        return view
    }()

    lazy var inProgressBar: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.blue
        view.gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer?.colors = CGColor.blues

        return view
    }()

    lazy var finishedBar: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.green
        view.gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        view.gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        view.gradientLayer?.colors = CGColor.greens
        
        return view
    }()

    lazy var unstartedTaskCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let value = unstartedCount
        label.text = "\(value)"
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .right

        label.textColor = .gray

        return label
    }()

    lazy var inProgressTaskCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let value = inProgressCount
        label.text = "\(value)"
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .right
        label.textColor = .gray

        return label
    }()

    lazy var finishedTaskCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let value = finishedCount
        label.text = "\(value)"
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .right

        label.textColor = .gray

        return label
    }()

    var unstartedWidthConstraint: NSLayoutConstraint!
    var inProgressWidthConstraint: NSLayoutConstraint!
    var finishedWidthConstraint: NSLayoutConstraint!

    private var totalNumberOfTasks: Int
    private var unstartedCount: Int
    private var inProgressCount: Int
    private var finishedCount: Int
    var grayBars = [UIView]()

    init(unstarted: Int, inProgress: Int, finished: Int) {
        self.unstartedCount = unstarted
        self.inProgressCount = inProgress
        self.finishedCount = finished
        self.totalNumberOfTasks = unstarted + inProgress + finished

        super.init(frame: CGRect.zero)

        layoutViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        let radius = frame.height * 0.18 / 2
        for bar in grayBars {
            bar.layer.cornerRadius = radius
        }
        inProgressBar.gradientLayer?.cornerRadius = radius
        unstartedBar.gradientLayer?.cornerRadius = radius
        finishedBar.gradientLayer?.cornerRadius = radius
        super.layoutSubviews()
    }

    func grayBar() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .fog

        return view
    }

    func barWidthPercent(for count: Int) -> CGFloat {
        guard totalNumberOfTasks > 0 else { return CGFloat.leastNormalMagnitude }
        let ratio = CGFloat(count)/CGFloat(totalNumberOfTasks)
        return ratio > 0 ? ratio : CGFloat.leastNormalMagnitude
    }

    func layoutViews() {
        NSLayoutConstraint.activate([
            layoutUnstartedRow(),
            layoutInProgressRow(),
            layoutFinishedRow(),
            ].flatMap({ $0 }))
        bringSubview(toFront: unstartedBar)
        bringSubview(toFront: inProgressBar)
        bringSubview(toFront: finishedBar)
    }

    func layoutUnstartedRow() -> [NSLayoutConstraint] {
        let gb = grayBar()
        addSubview(gb)
        addSubview(unstartedLabel)
        addSubview(unstartedBar)
        addSubview(unstartedTaskCountLabel)
        grayBars.append(gb)

        unstartedWidthConstraint = unstartedBar.widthAnchor.constraint(equalTo: gb.widthAnchor,
                                                                       multiplier: barWidthPercent(for: unstartedCount))

        return [
            unstartedLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.33),
            unstartedLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            unstartedLabel.topAnchor.constraint(equalTo: topAnchor),
            unstartedLabel.widthAnchor.constraint(equalTo: inProgressLabel.widthAnchor),
            gb.heightAnchor.constraint(equalTo: unstartedBar.heightAnchor, multiplier: 1),
            gb.leadingAnchor.constraint(equalTo: unstartedLabel.trailingAnchor, constant: 8),
            gb.trailingAnchor.constraint(equalTo: unstartedTaskCountLabel.leadingAnchor, constant: -10),
            gb.centerYAnchor.constraint(equalTo: unstartedLabel.centerYAnchor),
            unstartedBar.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.18),
            unstartedBar.centerYAnchor.constraint(equalTo: unstartedLabel.centerYAnchor),
            unstartedBar.leadingAnchor.constraint(equalTo: unstartedLabel.trailingAnchor, constant: 8),
            unstartedWidthConstraint,
            unstartedTaskCountLabel.centerYAnchor.constraint(equalTo: unstartedBar.centerYAnchor),
            unstartedTaskCountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                              constant: -4),
            unstartedTaskCountLabel.widthAnchor.constraint(equalToConstant: 20)
        ]
    }

    func layoutInProgressRow() -> [NSLayoutConstraint] {
        let gb = grayBar()
        addSubview(inProgressLabel)
        addSubview(gb)
        addSubview(inProgressBar)
        addSubview(inProgressTaskCountLabel)
        grayBars.append(gb)

        inProgressWidthConstraint = inProgressBar.widthAnchor.constraint(equalTo: gb.widthAnchor,
                                                                         multiplier: barWidthPercent(for: inProgressCount))

        return [
            inProgressLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.33),
            inProgressLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            inProgressLabel.topAnchor.constraint(equalTo: unstartedLabel.bottomAnchor),
            gb.heightAnchor.constraint(equalTo: inProgressBar.heightAnchor, multiplier: 1),
            gb.leadingAnchor.constraint(equalTo: inProgressLabel.trailingAnchor, constant: 8),
            gb.trailingAnchor.constraint(equalTo: inProgressTaskCountLabel.leadingAnchor, constant: -10),
            gb.centerYAnchor.constraint(equalTo: inProgressLabel.centerYAnchor),
            inProgressBar.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.18),
            inProgressLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.3),
            inProgressBar.centerYAnchor.constraint(equalTo: inProgressLabel.centerYAnchor),
            inProgressBar.leadingAnchor.constraint(equalTo: inProgressLabel.trailingAnchor, constant: 8),
            inProgressWidthConstraint,
            inProgressTaskCountLabel.centerYAnchor.constraint(equalTo: inProgressBar.centerYAnchor),
            inProgressTaskCountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                               constant: -4),
            inProgressTaskCountLabel.widthAnchor.constraint(equalToConstant: 20)
        ]
    }

    func layoutFinishedRow() -> [NSLayoutConstraint] {
        let gb = grayBar()
        addSubview(finishedLabel)
        addSubview(gb)
        addSubview(finishedBar)
        addSubview(finishedTaskCountLabel)
        grayBars.append(gb)

        finishedWidthConstraint = finishedBar.widthAnchor.constraint(equalTo: gb.widthAnchor,
                                                                     multiplier: barWidthPercent(for: finishedCount))

        return [
            finishedLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.33),
            finishedLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            finishedLabel.topAnchor.constraint(equalTo: inProgressLabel.bottomAnchor),
            finishedLabel.widthAnchor.constraint(equalTo: inProgressLabel.widthAnchor),
            gb.heightAnchor.constraint(equalTo: finishedBar.heightAnchor, multiplier: 1),
            gb.leadingAnchor.constraint(equalTo: finishedLabel.trailingAnchor, constant: 8),
            gb.trailingAnchor.constraint(equalTo: finishedTaskCountLabel.leadingAnchor, constant: -10),
            gb.centerYAnchor.constraint(equalTo: finishedLabel.centerYAnchor),
            finishedBar.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.18),
            finishedBar.centerYAnchor.constraint(equalTo: finishedLabel.centerYAnchor),
            finishedBar.leadingAnchor.constraint(equalTo: finishedLabel.trailingAnchor, constant: 8),
            finishedWidthConstraint,
            finishedTaskCountLabel.centerYAnchor.constraint(equalTo: finishedBar.centerYAnchor),
            finishedTaskCountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                             constant: -4),
            finishedTaskCountLabel.widthAnchor.constraint(equalToConstant: 20)
        ]
    }

    func updateTaskCounts(unstarted: Int,
                          inProgress: Int,
                          finished: Int) {
        guard unstarted != unstartedCount ||
            inProgress != inProgressCount ||
            finished != finishedCount
            else { return }

        totalNumberOfTasks = unstarted + inProgress + finished
        unstartedCount = unstarted
        inProgressCount = inProgress
        finishedCount = finished

        unstartedTaskCountLabel.text = "\(unstarted)"
        inProgressTaskCountLabel.text = "\(inProgress)"
        finishedTaskCountLabel.text = "\(finished)"

        let unstartedMultiplier = barWidthPercent(for: unstarted)
        let inProgressMultiplier = barWidthPercent(for: inProgress)
        let finishedMultiplier = barWidthPercent(for: finished)

        unstartedWidthConstraint = NSLayoutConstraint.changeMultiplier(unstartedWidthConstraint, multiplier: unstartedMultiplier)

        inProgressWidthConstraint = NSLayoutConstraint.changeMultiplier(inProgressWidthConstraint, multiplier: inProgressMultiplier)

        finishedWidthConstraint = NSLayoutConstraint.changeMultiplier(finishedWidthConstraint, multiplier: finishedMultiplier)

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
}

extension NSLayoutConstraint {
    static func changeMultiplier(_ constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: constraint.firstItem as Any,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: multiplier,
            constant: constraint.constant)

        newConstraint.priority = constraint.priority

        NSLayoutConstraint.deactivate([constraint])
        NSLayoutConstraint.activate([newConstraint])

        return newConstraint
    }
}
