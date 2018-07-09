import UIKit

class NoTasksView: UIView {

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "NoTasks-Gray")
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.textColor = .gray
        label.text = "No Tasks"
        label.clipsToBounds = true
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.textColor = .lightGray
        label.text = "Tap the + in the top corner to add one!"
        label.clipsToBounds = true
        return label
    }()

    init() {
        super.init(frame: .zero)
        layoutView()
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func layoutView() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)

        let aspectRatio = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).with(priority: .required)

        let width = imageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.3).with(priority: .required)

        let height = imageView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.3).with(priority: .required)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            aspectRatio,
            width,
            height,
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).with(priority: .defaultHigh),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
    }
}
