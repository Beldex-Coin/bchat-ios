// Copyright © 2022 Beldex International Limited OU. All rights reserved.
import UIKit
class MyWalletReceiveVC: BaseVC,UITextFieldDelegate {
    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var shareref:UIButton!
    @IBOutlet weak var copyRef:UIButton!
    @IBOutlet weak var qrCodeImageView:UIImageView!
    @IBOutlet weak var lbladdress:UILabel!
    @IBOutlet weak var backgroundShareView:UIView!
    @IBOutlet weak var backgroundEnteramountView:UIView!
    @IBOutlet weak var shareImh:UIImageView!
    @IBOutlet weak var txtamount:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        self.title = "Receive"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        txtamount.addTarget(self, action: #selector(onAmountChange), for: .editingChanged)
        txtamount.delegate = self
        txtamount.keyboardType = .decimalPad
        //Keyboard Done Option
        txtamount.addDoneButtonKeybord()
        
        if !SaveUserDefaultsData.WalletpublicAddress.isEmpty {
            lbladdress.text = SaveUserDefaultsData.WalletpublicAddress
        }
        backgroundView.layer.cornerRadius = 10
        shareref.layer.cornerRadius = 6
        qrCodeImageView.layer.cornerRadius = 10
        backgroundShareView.layer.cornerRadius = 6
        backgroundEnteramountView.layer.cornerRadius = 6
        
        let logoName2 = isLightMode ? "share" : "share"
        shareImh.image = UIImage(named: logoName2)!
        let logoName = isLightMode ? "copy-dark" : "copy_white"
        copyRef.setImage(UIImage(named: logoName), for: .normal)
        
        qrCodeImageView.image = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(txtamount.text!)")
        qrCodeImageView.contentMode = .scaleAspectFit
        
        let dismiss: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismiss)
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // txtamout only sigle . enter
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let components = string.components(separatedBy: inverseSet)
        let filtered = components.joined(separator: "")
        if filtered == string {
            if textField == txtamount{
                let currentString: NSString = textField.text! as NSString
                let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= 16
            }
            return true
        } else {
            if string == "." {
                let countdots = txtamount.text!.components(separatedBy:".").count - 1
                if countdots == 0 {
                    return true
                }else{
                    if countdots > 0 && string == "." {
                        return false
                    } else {
                        return true
                    }
                }
            }
            else{
                return false
            }
        }
    }
    
    // Textfiled Paste option hide
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:))
        {
            return true
        } else if action == Selector(("_lookup:")) || action == Selector(("_share:")) || action == Selector(("_define:")) || action == #selector(delete(_:)) || action == #selector(copy(_:)) || action == #selector(cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if txtamount.text!.count == 0 {
            qrCodeImageView.image = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(txtamount.text!)")
            qrCodeImageView.contentMode = .scaleAspectFit
        }else {
            if let mystring = txtamount.text {
                qrCodeImageView.image = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(mystring)")
            } else {
                qrCodeImageView.image = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)")
            }
        }
    }
    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setDefaults()
            //Margin
            //filter.setValue(7.00, forKey: "inputQuietSpace")
            filter.setValue(data, forKey: "inputMessage")
            //Scaling
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                let context:CIContext = CIContext.init(options: nil)
                let cgImage:CGImage = context.createCGImage(output, from: output.extent)!
                let rawImage:UIImage = UIImage.init(cgImage: cgImage)
                //Refinement code to allow conversion to NSData or share UIImage. Code here:
                let cgimage: CGImage = (rawImage.cgImage)!
                let cropZone = CGRect(x: 0, y: 0, width: Int(rawImage.size.width), height: Int(rawImage.size.height))
                let cWidth: size_t = size_t(cropZone.size.width)
                let cHeight: size_t = size_t(cropZone.size.height)
                let bitsPerComponent: size_t = cgimage.bitsPerComponent
                //THE OPERATIONS ORDER COULD BE FLIPPED, ALTHOUGH, IT DOESN'T AFFECT THE RESULT
                let bytesPerRow = (cgimage.bytesPerRow) / (cgimage.width * cWidth)
                let context2: CGContext = CGContext(data: nil, width: cWidth, height: cHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgimage.bitmapInfo.rawValue)!
                context2.draw(cgimage, in: cropZone)
                let result: CGImage = context2.makeImage()!
                let finalImage = UIImage(cgImage: result)
                return finalImage
            }
        }
        return nil
    }
    @objc private func onAmountChange(_ textField: UITextField) {
        if txtamount.text!.count == 0 {
            qrCodeImageView.image = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(txtamount.text!)")
            qrCodeImageView.contentMode = .scaleAspectFit
        }else {
            if let mystring = txtamount.text {
                qrCodeImageView.image = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(mystring)")
            } else {
                qrCodeImageView.image = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)")
            }
        }
    }
    @IBAction func shareAction(sender:UIButton){
        if txtamount.text!.isEmpty {
            let alert = UIAlertController(title: "My Wallet", message: "Pls Enter amount", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else {
            let indexOfString = txtamount.text!
            let lastString = txtamount.text!.index(before: txtamount.text!.endIndex)
            if txtamount.text?.count == 0 {
                let alert = UIAlertController(title: "My Wallet", message: "Pls Enter amount", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else if txtamount.text! == "." || Int(txtamount.text!) == 0 || indexOfString.count
                        > 16 || txtamount.text![lastString] == "." {
                let alert = UIAlertController(title: "My Wallet", message: "Pls Enter Proper amount", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                let qrCode = generateBarcode(from: "\(SaveUserDefaultsData.WalletpublicAddress)" + "?amount=\(txtamount.text!)")
                let shareVC = UIActivityViewController(activityItems: [ qrCode! ], applicationActivities: nil)
                self.navigationController!.present(shareVC, animated: true, completion: nil)
            }
        }
    }
    @IBAction func CopyAction(sender:UIButton){
        UIPasteboard.general.string = "\(SaveUserDefaultsData.WalletpublicAddress)"
        self.showToastMsg(message: "Your Beldex Address is copied to clipboard", seconds: 1.0)
    }
}
