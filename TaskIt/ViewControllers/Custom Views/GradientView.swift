import UIKit

class GradientView: UIView {
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer? { return layer as? CAGradientLayer }
}

class GradientButton: UIButton {
    override class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    var gradientLayer: CAGradientLayer? { return layer as? CAGradientLayer }
}

extension CAGradientLayer {
    enum Distribution {
        case leftRight
        case topBottom
        case topLeftBottomRight
        case bottomLeftTopRight
        case custom(start: CGPoint, end: CGPoint)

        func startPoint() -> CGPoint {
            switch self {
            case .leftRight: return CGPoint(x: 0, y: 0.5)
            case .topBottom: return CGPoint(x: 0.5, y: 0)
            case .topLeftBottomRight: return .zero
            case .bottomLeftTopRight: return CGPoint(x: 0, y: 1)
            case .custom(let start, _): return start
            }
        }

        func endPoint() -> CGPoint {
            switch self {
            case .leftRight: return CGPoint(x: 1, y: 0.5)
            case .topBottom: return CGPoint(x: 0.5, y: 1)
            case .topLeftBottomRight: return CGPoint(x: 1, y: 1)
            case .bottomLeftTopRight: return CGPoint(x: 1, y: 0)
            case .custom(_, let end): return end
            }
        }
    }

    func setDistribution(_ distribution: Distribution) {
        self.startPoint = distribution.startPoint()
        self.endPoint = distribution.endPoint()
    }
}
