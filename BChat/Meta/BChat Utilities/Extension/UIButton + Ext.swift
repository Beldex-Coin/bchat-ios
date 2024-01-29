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
    
    func addRightIcon(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        addSubview(imageView)
        let length = CGFloat(15)
        titleEdgeInsets.right += length
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
    
    func addRightIconLongSpace(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        addSubview(imageView)
        let length = CGFloat(15)
        titleEdgeInsets.right += length
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: 60),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: length),
            imageView.heightAnchor.constraint(equalToConstant: length)
        ])
    }
    
}
