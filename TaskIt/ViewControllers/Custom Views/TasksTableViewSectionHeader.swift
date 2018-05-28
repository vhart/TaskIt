import UIKit

class TasksTableViewSectionHeader: UITableViewHeaderFooterView {

    enum State {
        case currentSprint(Int)
        case remaining
        case finished
    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    var state: State? {
        didSet {
            guard let state = state else { return }
            update(with: state)
        }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layoutViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let state = state { update(with: state) }
    }

    private func layoutViews() {
        contentView.backgroundColor = .white
        contentView.addSubview(imageView)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
    }

    private func update(with state: State) {
        switch state {
        case .currentSprint(let week):
            label.text = "Week \(week)"
            imageView.image = #imageLiteral(resourceName: "in-flight")
        case .remaining:
            label.text = "Remaining"
            let height = imageView.frame.height
            let buffer = height * 0.08
            imageView.image = #imageLiteral(resourceName: "unplannedIconRed").imageWithInsets(insetDimen: buffer)
        case .finished:
            label.text = "Finished"
            imageView.image = #imageLiteral(resourceName: "checked")
        }
    }
}
