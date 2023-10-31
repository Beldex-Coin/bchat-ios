// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit

class MyWalletInstructionsVC: BaseVC {

    @IBOutlet weak var backgroundView:UIView!
    @IBOutlet weak var topOftheStringTitle:UILabel!
    @IBOutlet weak var middleOftheStringTitle:UILabel!
    @IBOutlet weak var bottomOftheStringTitle:UILabel!
    @IBOutlet weak var enableWalletbtn:UIButton!
    @IBOutlet weak var isCheckedActionbtn:UIButton!
    var flagvalue:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Wallet"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        backgroundView.layer.cornerRadius = 6
        
        // 1.Your input string
        let text = "You can Send and Receive BDX with the BChat integrated wallet."
        let redTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.accent.cgColor]
        let whiteTextAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.bchatLabelNameColor.cgColor]
        let attributedText = NSMutableAttributedString(string: text, attributes: whiteTextAttributes)
        let range = (text as NSString).range(of: "Send and Receive BDX")
        attributedText.addAttributes(redTextAttributes, range: range)
        topOftheStringTitle.attributedText = attributedText
        
        // 2.Your input string
        let text2 = "The BChat wallet is beta. Constant updates are released in newer versions of the app to enhance the integrated wallet functionality."
        let redTextAttributes2: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.bchatLabelNameColor.cgColor]
        let whiteTextAttributes2: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.bchatLabelNameColor.cgColor]
        let attributedText2 = NSMutableAttributedString(string: text2, attributes: whiteTextAttributes2)
        let range2 = (text2 as NSString).range(of: "BChat wallet is beta")
        attributedText2.addAttributes(redTextAttributes2, range: range2)
        middleOftheStringTitle.attributedText = attributedText2
        
        // 3.Your input string
        let text3 = "You can enable or disable the wallet using the Start wallet feature under Settings > Wallet settings."
        let redTextAttributes3: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.accent.cgColor]
        let whiteTextAttributes3: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.bchatLabelNameColor.cgColor]
        let attributedText3 = NSMutableAttributedString(string: text3, attributes: whiteTextAttributes3)
        let range3 = (text3 as NSString).range(of: "Settings > Wallet settings.")
        attributedText3.addAttributes(redTextAttributes3, range: range3)
        bottomOftheStringTitle.attributedText = attributedText3
        
        enableWalletbtn.layer.cornerRadius = 6
        
        if isLightMode {
            yesIUnderstandDarkMode()
        }else {
            yesIUnderstandWhiteMode()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        flagvalue = false
        if isLightMode {
            yesIUnderstandDarkMode()
        }else {
            yesIUnderstandWhiteMode()
        }
    }

    func yesIUnderstandWhiteMode(){
        enableWalletbtn.backgroundColor = UIColor.lightGray
        let image1 = UIImage(named: "unChecked_dark.png")!
        let tintedImage = image1.withRenderingMode(.alwaysTemplate)
        self.isCheckedActionbtn.setImage(tintedImage, for: .normal)
        isCheckedActionbtn.tintColor = .white
    }
    func yesIUnderstandDarkMode(){
        enableWalletbtn.backgroundColor = UIColor.lightGray
        let image1 = UIImage(named: "unChecked_dark.png")!
        let tintedImage = image1.withRenderingMode(.alwaysTemplate)
        self.isCheckedActionbtn.setImage(tintedImage, for: .normal)
        isCheckedActionbtn.tintColor = .black
    }
    
    
    // MARK: - Navigation
    @IBAction func isCheckActionTapped(_ sender: UIButton) {
        isCheckedActionbtn.isSelected = !isCheckedActionbtn.isSelected
        if isCheckedActionbtn.isSelected {
            flagvalue = true
            enableWalletbtn.backgroundColor = Colors.bchatButtonColor
            let img = UIImage(named: "checked_img.png")!
            let tintedImage = img.withRenderingMode(.alwaysTemplate)
            self.isCheckedActionbtn.setImage(tintedImage, for: .normal)
            isCheckedActionbtn.tintColor = isLightMode ? .black : .white
        }else {
            flagvalue = false
            if isLightMode {
                yesIUnderstandDarkMode()
            }else {
                yesIUnderstandWhiteMode()
            }
        }
    }
    
    @IBAction func isEnableWalletTapped(_ sender: UIButton) {
        
    }

}
