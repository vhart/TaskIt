import UIKit

extension UIColor {
    convenience init? (hexString: String) {
        let hexPattern = try! NSRegularExpression(pattern: "^[0-9a-fA-F]{6}$",
                                                  options: [.anchorsMatchLines])
        let range =  NSRange(location: 0, length: hexString.count)

        guard hexPattern.matches(in: hexString,
                                 options: [],
                                 range: range).count == 1
            else { return nil }

        let positionR = hexString.index(hexString.startIndex, offsetBy: 2)
        let positionG = hexString.index(hexString.startIndex, offsetBy: 4)

        guard let r = Double("0x" + hexString[..<positionR]),
            let g = Double("0x" + hexString[positionR..<positionG]),
            let b = Double("0x" + hexString[positionG...]) else { return nil }

        self.init(red:   CGFloat(r / 255),
                  green: CGFloat(g / 255),
                  blue:  CGFloat(b / 255),
                  alpha: 1)
    }
}

extension UIColor {
    static let tangerine = UIColor(hexString: "fe8c00")!
    static let tomato    = UIColor(hexString: "f83600")!
    static let bluejay   = UIColor(hexString: "00d2ff")!
    static let blueberry = UIColor(hexString: "3a7bd5")!
    static let grass     = UIColor(hexString: "a8e063")!
    static let lime      = UIColor(hexString: "24fe41")!
    static let indigo    = UIColor(hexString: "3f5efb")!
    static let plum      = UIColor(hexString: "5c258d")!
    static let fog       = UIColor(hexString: "ebedee")!
    static let ocean     = UIColor(hexString: "219DFF")!
    static let limerick  = UIColor(hexString: "a2c115")!
    static let spring    = UIColor(hexString: "0fd850")!
    static let kinda     = UIColor(hexString: "50cc7f")!
    static let gold      = UIColor(hexString: "D4AF37")!
    static let lemon     = UIColor(hexString: "f9f047")!
}

extension CGColor {
    static let reds    = [UIColor.tangerine.cgColor, UIColor.tomato.cgColor]
    static let blues   = [UIColor.bluejay.cgColor, UIColor.blueberry.cgColor]
    static let greens  = [UIColor.green.cgColor, UIColor.spring.cgColor]//[UIColor.grass.cgColor, UIColor.lime.cgColor]
    static let golds   = [UIColor.lemon.cgColor, UIColor.gold.cgColor]
    static let purples = [UIColor.indigo.cgColor, UIColor.plum.cgColor]
}
