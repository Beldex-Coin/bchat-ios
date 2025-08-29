import UIKit

@objc(LKFonts)
public final class Fonts: NSObject {
    
    @objc public static func OpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }
    @objc public static func boldOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
    }
    @objc public static func mediumOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }
    @objc public static func extraBoldOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-ExtraBold", size: size) ?? .systemFont(ofSize: size, weight: .heavy)
    }
    @objc public static func semiOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Semibold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }
    @objc public static func lightOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Light", size: size) ?? .systemFont(ofSize: size, weight: .light)
    }
}

