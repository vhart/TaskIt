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

    subscript(type: ConstraintType) -> NSLayoutConstraint? {
        get {
            return constraints[type]
        }

        set(newValue) {
            constraints[type] = newValue
        }
    }
}
