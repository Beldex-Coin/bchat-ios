//
//  UIButton + Ext.swift


import UIKit

extension UIButton {
    
    public struct TitleAttributes {
        let title: String
        let titleColor: UIColor
        let state: State
        
        init(_ title: String, titleColor: UIColor, state: State) {
            self.title = title
            self.titleColor = titleColor
            self.state = state
        }
    }
    
    public class func create(_ title: String? = nil,
                             titleColor: UIColor? = nil,
                             image: UIImage? = nil,
                             backgroundImage: UIImage?) -> Self {
        let btn = self.init()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.setImage(image, for: .normal)
        btn.setBackgroundImage(image, for: .normal)
        return btn
    }
    
}
