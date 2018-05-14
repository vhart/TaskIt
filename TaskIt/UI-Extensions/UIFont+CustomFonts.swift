import UIKit

enum FontName: String {
    case avenirNextBold = "AvenirNext-Bold"
    case avenirNextRegular = "AvenirNext-Regular"
    case avenirNextMedium = "AvenirNext-Medium"
}

extension UIFont {
    convenience init(fontName: FontName, size: CGFloat) {
        self.init(name: fontName.rawValue, size: size)!
    }
}
