import UIKit

struct AnimationConstraints {
    enum ConstraintType {
        case top
        case bottom
        case leading
        case trailing
        case centerX
        case centerY
        case width
        case height
    }

    var constraints = [ConstraintType: NSLayoutConstraint]()
}
