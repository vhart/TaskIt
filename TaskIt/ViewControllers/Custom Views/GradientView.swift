import UIKit

class GradientView: UIView {
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer? { return layer as? CAGradientLayer }
}
