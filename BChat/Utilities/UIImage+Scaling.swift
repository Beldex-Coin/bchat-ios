
extension UIImage {
    
    func scaled(to size: CGSize) -> UIImage {
        var rect = CGRect.zero
        let aspectRatio = min(size.width / self.size.width, size.height / self.size.height)
        rect.size.width = self.size.width * aspectRatio
        rect.size.height = self.size.height * aspectRatio
        rect.origin.x = (size.width - rect.size.width) / 2
        rect.origin.y = (size.height - rect.size.height) / 2
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIImage {
    
    /// place the imageView inside a container view
    /// - parameter superView: the containerView that you want to place the Image inside
    /// - parameter width: width of imageView, if you opt to not give the value, it will take default value of 100
    /// - parameter height: height of imageView, if you opt to not give the value, it will take default value of 30
    func addToCenter(of superView: UIView, width: CGFloat = 120, height: CGFloat = 50) {
        let overlayImageView = UIImageView(image: self)
        
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .scaleAspectFit
        superView.addSubview(overlayImageView)
        
        let centerXConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerX, relatedBy: .equal, toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: overlayImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120)
        let height = NSLayoutConstraint(item: overlayImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let centerYConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerY, relatedBy: .equal, toItem: superView, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([width, height, centerXConst, centerYConst])
    }
}
