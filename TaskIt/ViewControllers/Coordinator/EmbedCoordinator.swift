import UIKit

class EmbedCoordinator {
    private weak var parent: UIViewController?
    private var presenting: UIViewController?

    init(base: UIViewController) {
        self.parent = base
    }

    func embed(child: UIViewController, in container: UIView) {
        removeCurrentEmbeddedViewController()

        guard let parent = parent else { return }

        parent.addChildViewController(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: container.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
        child.willMove(toParentViewController: parent)
        child.didMove(toParentViewController: parent)

        presenting = child
    }

    func removeCurrentEmbeddedViewController() {
        presenting?.willMove(toParentViewController: nil)
        presenting?.view.removeFromSuperview()
        presenting?.removeFromParentViewController()
        presenting = nil
    }

}
