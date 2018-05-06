import UIKit

enum FontName: String {
    case avenirNextBold = "AvenirNext-Bold"
    case avenirNextRegular = "AvenirNext-Regular"
}

extension UIFont {
    convenience init(fontName: FontName, size: CGFloat) {
        self.init(name: fontName.rawValue, size: size)!
    }
}
