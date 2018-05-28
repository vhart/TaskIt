import UIKit

class RootViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            navigationItem.title = "Dashboard"
        } else {
            navigationItem.title = "History"
        }
    }
}
