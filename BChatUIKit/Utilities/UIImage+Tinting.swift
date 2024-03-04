import UIKit

public extension UIImage {
    
    func withTint(_ color: UIColor) -> UIImage? {
        let template = self.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: template)
        imageView.tintColor = color
        return imageView.toImage(isOpaque: imageView.isOpaque, scale: UIScreen.main.scale)
    }
    
    static func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            // Scaling
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                let context = CIContext(options: nil)
                if let cgImage = context.createCGImage(output, from: output.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
}
