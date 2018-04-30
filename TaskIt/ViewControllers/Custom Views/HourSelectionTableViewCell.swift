import UIKit

class HourSelectionTableViewCell: UITableViewCell {

    lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 20, weight: .medium)
        l.backgroundColor = .clear
        l.textColor = .white
        l.textAlignment = .center
        
        contentView.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: contentView.topAnchor),
            l.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            l.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            l.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])

        return l
    }()

    func setUpForSelection() {
        backgroundColor = .grass
        label.textColor = .white
    }

    func setUpForNoOption() {
        backgroundColor = .white
        label.textColor = .red
    }

    func setUpForNotSelected() {
        backgroundColor = .white
        label.textColor = .black
    }
}
