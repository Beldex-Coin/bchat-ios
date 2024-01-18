import UIKit

@objc(LKFonts)
public final class Fonts : NSObject {
    
    @objc public static func OpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Regular", size: size)!
    }
    @objc public static func boldOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: size)!
    }
    @objc public static func mediumOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Medium", size: size)!
    }
    @objc public static func extraBoldOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-ExtraBold", size: size)!
    }
    @objc public static func semiOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Semibold", size: size)!
    }
    
    
}

