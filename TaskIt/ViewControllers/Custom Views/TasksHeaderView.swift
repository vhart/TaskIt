import UIKit

enum HeaderType {
    case sprint(Int)
    case backlog
    case finished

    var description: String {
        switch self {
        case .sprint(let week):
            return "Week \(week)"
        case .backlog:
            return "Remaining"
        case .finished:
            return "Finished"
        }
    }
}

class TasksHeaderView: UIView {

    private let type: HeaderType!

    private var onAddTapped: (() -> Void)?

    lazy var container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    lazy var addButton: UIButton = {
        let b = UIButton(type: UIButtonType.contactAdd)
        b.tintColor = .white
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = type.description
        l.textColor = .white
        l.font = .systemFont(ofSize: 18, weight: .medium)
        return l
    }()

    init(type: HeaderType, frame: CGRect, showAddButton: Bool = false) {
        self.type = type
        super.init(frame: frame)

        layout()
        addButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func layout() {
        self.addSubview(container)
        container.addSubview(label)
        container.addSubview(addButton)

        let color: UIColor
        switch type! {
        case .sprint(_): color = .indigo
        case .backlog: color = .ocean
        case .finished: color = .spring
        }
        container.backgroundColor = color
        addButton.isHidden = true

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            addButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            ])
    }

    @objc private func onButtonTapped() {
        onAddTapped?()
    }

}
