import UIKit

class TapRecognizingView: UIView {

    var onTap: (() -> Void)?

    var ignoreTaps = false

    init() {
        super.init(frame: CGRect.zero)
        addGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        addGestureRecognizer(tapGesture)
    }

    @objc private func didTap(sender: UITapGestureRecognizer) {
        guard sender.view == self && !ignoreTaps else { return }
        onTap?()
    }
}

class TaskStateButtonView: UIView {

    let taskState: TaskState

    lazy var button: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = taskState.text
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black

        return label
    }()

    init(taskState: TaskState) {
        self.taskState = taskState
        super.init(frame: CGRect.zero)

        setUpViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        button.layer.cornerRadius = frame.width / 2
    }

    private func setUpViews() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.widthAnchor.constraint(equalTo: widthAnchor),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
    }
}
