import UIKit

@objc(LKFonts)
public final class Fonts : NSObject {
    
    @objc public static func OpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Regular", size: size)!
    }
    
    @objc public static func boldOpenSans(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: size)!
    }
}

//spaceMono
//boldSpaceMono
