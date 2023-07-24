//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import MediaPlayer
import BChatUIKit
import NVActivityIndicatorView
import ImageIO

// A modal view that be used during blocking interactions (e.g. waiting on response from
// service or on the completion of a long-running local operation).
@objc
public class ModalActivityIndicatorViewController: OWSViewController {
    let canCancel: Bool
    
    let message: String?
    
    @objc
    public var wasCancelled: Bool = false
    
    private lazy var spinner: NVActivityIndicatorView = {
        let result = NVActivityIndicatorView(frame: CGRect.zero, type: .circleStrokeSpin, color: .white, padding: nil)
        result.set(.width, to: 64)
        result.set(.height, to: 64)
        return result
    }()
    
    private lazy var gifimageView: UIImageView = {
        let theImageView = UIImageView()
        theImageView.set(.width, to: 100)
        theImageView.set(.height, to: 100)
        theImageView.layer.masksToBounds = true
        theImageView.widthAnchor.constraint(equalToConstant: 180).isActive = true
        if isLightMode {
            do {
                let imageData = try Data(contentsOf: Bundle.main.url(forResource: "bchatlogo_animation", withExtension: "gif")!)
                theImageView.image = UIImage.gif(data: imageData)
            } catch {
                print(error)
            }
        }else {
            do {
                let imageData = try Data(contentsOf: Bundle.main.url(forResource: "bchatlogo_animation", withExtension: "gif")!)
                theImageView.image = UIImage.gif(data: imageData)
            } catch {
                print(error)
            }
        }
        theImageView.translatesAutoresizingMaskIntoConstraints = false
        return theImageView
    }()
    
    var wasDimissed: Bool = false
    
    // MARK: Initializers
    
    @available(*, unavailable, message:"use other constructor instead.")
    public required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
    public required init(canCancel: Bool = false, message: String? = nil) {
        self.canCancel = canCancel
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc
    public class func present(fromViewController: UIViewController, canCancel: Bool = false, message: String? = nil,
                              backgroundBlock : @escaping (ModalActivityIndicatorViewController) -> Void) {
        AssertIsOnMainThread()
        
        let view = ModalActivityIndicatorViewController(canCancel: canCancel, message: message)
        // Present this modal _over_ the current view contents.
        view.modalPresentationStyle = .overFullScreen
        view.modalTransitionStyle = .crossDissolve
        fromViewController.present(view, animated: false) {
            DispatchQueue.global().async {
                backgroundBlock(view)
            }
        }
    }
    
    @objc
    public func dismiss(completion : @escaping () -> Void) {
        AssertIsOnMainThread()
        if !wasDimissed {
            // Only dismiss once.
            self.dismiss(animated: false, completion: completion)
            wasDimissed = true
        } else {
            // If already dismissed, wait a beat then call completion.
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    public override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.view.isOpaque = false
        
        if let message = message {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = Fonts.OpenSans(ofSize: Values.mediumFontSize)
            messageLabel.textColor = UIColor.white
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.lineBreakMode = .byWordWrapping
            messageLabel.set(.width, to: UIScreen.main.bounds.width - 2 * Values.mediumSpacing)
            let stackView = UIStackView(arrangedSubviews: [ messageLabel, gifimageView ])
            stackView.axis = .vertical
            stackView.spacing = Values.largeSpacing
            stackView.alignment = .center
            self.view.addSubview(stackView)
            stackView.center(in: self.view)
        } else {
            self.view.addSubview(gifimageView)
            gifimageView.autoCenterInSuperview()
        }
        
        if canCancel {
            let cancelButton = UIButton(type: .custom)
            cancelButton.setTitle(CommonStrings.cancelButton, for: .normal)
            cancelButton.setTitleColor(UIColor.white, for: .normal)
            cancelButton.backgroundColor = UIColor.ows_darkGray
            cancelButton.titleLabel?.font = UIFont.ows_mediumFont(withSize: ScaleFromIPhone5To7Plus(18, 22))
            cancelButton.layer.cornerRadius = ScaleFromIPhone5To7Plus(4, 5)
            cancelButton.clipsToBounds = true
            cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
            let buttonWidth = ScaleFromIPhone5To7Plus(140, 160)
            let buttonHeight = ScaleFromIPhone5To7Plus(40, 50)
            self.view.addSubview(cancelButton)
            cancelButton.autoHCenterInSuperview()
            cancelButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 50)
            cancelButton.autoSetDimension(.width, toSize: buttonWidth)
            cancelButton.autoSetDimension(.height, toSize: buttonHeight)
        }
        
        // Hide the modal until the presentation animation completes.
        self.view.layer.opacity = 0.0
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.gifimageView.startAnimating()
        
        // Fade in the modal
        UIView.animate(withDuration: 0.35) {
            self.view.layer.opacity = 1.0
        }
    }
    
    @objc func cancelPressed() {
        AssertIsOnMainThread()
        
        wasCancelled = true
        
        dismiss { }
    }
}
extension UIImageView {
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
extension UIImage {
    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("SwiftGif: Source for the image does not exist")
            return nil
        }
        return UIImage.animatedImageWithSource(source)
    }
    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }
        return gif(data: imageData)
    }
    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
            print("SwiftGif: This image named \"\(name)\" does not exist")
            return nil
        }
        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        return gif(data: imageData)
    }
    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }
        return gif(data: dataAsset.data)
    }
    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }
        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }
        return delay
    }
    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }
        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }
        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!
            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }
    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }
        var gcd = array[0]
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        return gcd
    }
    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }
            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        // Calculate full duration
        let duration: Int = {
            var sum = 0
            for val: Int in delays {
                sum += val
            }
            return sum
        }()
        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        return animation
    }
}









