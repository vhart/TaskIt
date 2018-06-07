import UIKit

class PermaColorView: UIView {
    var color: UIColor = .clear {
        didSet {
            backgroundColor = color
        }
    }

    override var backgroundColor: UIColor? {
        set {
            guard newValue == color else { return }
            super.backgroundColor = newValue
        }

        get {
            return super.backgroundColor
        }
    }
}

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var stateIndicatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateIndicatorView: PermaColorView!

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskDescriptionLabel: UILabel!

    lazy var gradientView: GradientView = {
        let v = GradientView()
        v.translatesAutoresizingMaskIntoConstraints = false
        stateIndicatorView.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: stateIndicatorView.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: stateIndicatorView.trailingAnchor),
            v.topAnchor.constraint(equalTo: stateIndicatorView.topAnchor),
            v.bottomAnchor.constraint(equalTo: stateIndicatorView.bottomAnchor),
            ])

        return v
    }()

    var viewModel: TaskTableViewCellViewModel? = nil {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        guard let vm = viewModel else { return }
        selectionStyle = .none

        taskTitleLabel.text = vm.title
        taskDescriptionLabel.text = vm.description
        timeLabel.text = vm.time

        stateIndicatorView.color = vm.indicatorColor
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        contentView.layer.cornerRadius = 4
    }
}

enum TaskIndicatorVisibility {
    case hide
    case show
}

struct TaskTableViewCellViewModel {
    let title: String
    let description: String
    let time: String
    let indicatorColor: UIColor
    let gradient: [CGColor]

    init(task: Task) {
        self.title = task.title
        self.description = task.taskDetails

        self.time = task.estimatedDuration.asHourString + " hrs"

        switch task.state {
        case .unstarted:
            self.indicatorColor = .tomato
            self.gradient = CGColor.reds
        case .inProgress:
            self.indicatorColor = .ocean
            self.gradient = CGColor.blues
        case .finished:
            self.indicatorColor = .spring
            self.gradient = CGColor.greens
        }
    }
}
