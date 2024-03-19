// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit

class EnableWalletVC: BaseVC {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.seedBackgroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.noBorderColor3.cgColor
        return stackView
    }()
    lazy var greenDotView1: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00B504)
        View.layer.cornerRadius = 4
        return View
    }()
    private lazy var infoLabel1: UILabel = {
        let result = UILabel()
        result.text = "You can Send and Receive BDX with the BChat integrated wallet."
        result.textColor = Colors.titleColor4
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.lineBreakMode = .byWordWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.spacing = 1.25
        return result
    }()
    lazy var greenDotView2: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00B504)
        View.layer.cornerRadius = 4
        return View
    }()
    private lazy var infoLabel2: UILabel = {
        let result = UILabel()
        result.text = "The 'Pay as you Chat' feature is an easy-pay feature. You can send BDX to your friends right from the chat window."
        result.textColor = Colors.titleColor4
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.lineBreakMode = .byWordWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.spacing = 1.25
        return result
    }()
    lazy var greenDotView3: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00B504)
        View.layer.cornerRadius = 4
        return View
    }()
    private lazy var infoLabel3: UILabel = {
        let result = UILabel()
        result.text = "The BChat wallet is beta. Constant updates are released in newer versions of the app to enhance the integrated wallet functionality."
        result.textColor = Colors.titleColor4
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.lineBreakMode = .byWordWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.spacing = 1.25
        return result
    }()
    lazy var greenDotView4: UIView = {
        let View = UIView()
        View.translatesAutoresizingMaskIntoConstraints = false
        View.backgroundColor = UIColor(hex: 0x00B504)
        View.layer.cornerRadius = 4
        return View
    }()
    private lazy var infoLabel4: UILabel = {
        let result = UILabel()
        result.text = "You can enable or disable the wallet using the Start wallet feature under Settings > Wallet settings."
        result.textColor = Colors.titleColor4
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.lineBreakMode = .byWordWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.spacing = 1.25
        return result
    }()
    lazy var bottomStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fill
        result.spacing = 9
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    private lazy var confirmationLabel: UILabel = {
        let result = UILabel()
        result.text = "Yes, I Understand"
        result.textColor = Colors.titleColor4
        result.font = Fonts.OpenSans(ofSize: 15)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    lazy var selectionButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "ic_buttonBorder"), for: .normal)
        button.setBackgroundImage(UIImage(named: "ic_buttonFill"), for: .selected)
        return button
    }()
    private lazy var enableButton: UIButton = {
        let button = UIButton()
        button.setTitle("Enable Wallet", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cellGroundColor2
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 15)
        button.setTitleColor(Colors.buttonDisableColor, for: .normal)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .selected)
        button.addTarget(self, action: #selector(enableButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.mainBackGroundColor4
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
        
//        let yourBackImage = UIImage(named: "ic_back_newNavBar")
//        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
//        self.navigationController?.navigationBar.backItem?.title = "Custom"
//
//        navigationItem.hidesBackButton = true
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back_newNavBar"), style: .plain, target: self, action: nil)

        
        view.addSubview(backGroundView)
        backGroundView.addSubViews(greenDotView1, infoLabel1, greenDotView2, infoLabel2, greenDotView3, infoLabel3, greenDotView4, infoLabel4, bottomStackView)
        bottomStackView.addArrangedSubview(confirmationLabel)
        bottomStackView.addArrangedSubview(selectionButton)
        backGroundView.addSubview(enableButton)
        self.enableButton.isSelected = false
        
        let text = "You can Send and Receive BDX with the BChat integrated wallet."
        let attributedText = text.setColor(Colors.bothGreenColor, ofSubstring: "Send and Receive BDX")
        infoLabel1.attributedText = attributedText
        
        
        let text2 = "The 'Pay as you Chat' feature is an easy-pay feature. You can send BDX to your friends right from the chat window."
        let attributedText2 = text2.setColor(Colors.bothGreenColor, ofSubstring: "Pay as you Chat")
        infoLabel2.attributedText = attributedText2
        
        let text4 = "You can enable or disable the wallet using the Start wallet feature under Settings > Wallet settings."
        let attributedText4 = text4.setColor(Colors.bothGreenColor, ofSubstring: "Settings > Wallet settings.")
        infoLabel4.attributedText = attributedText4
        
        
        
        NSLayoutConstraint.activate([
//            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 27),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -27),
            greenDotView1.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 27),
            greenDotView1.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 40),
            greenDotView1.widthAnchor.constraint(equalToConstant: 8),
            greenDotView1.heightAnchor.constraint(equalToConstant: 8),
            infoLabel1.topAnchor.constraint(equalTo: greenDotView1.topAnchor, constant: -10),
            infoLabel1.leadingAnchor.constraint(equalTo: greenDotView1.trailingAnchor, constant: 14),
            infoLabel1.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -26),
            greenDotView2.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 27),
            greenDotView2.topAnchor.constraint(equalTo: greenDotView1.bottomAnchor, constant: 60),
            greenDotView2.widthAnchor.constraint(equalToConstant: 8),
            greenDotView2.heightAnchor.constraint(equalToConstant: 8),
            infoLabel2.topAnchor.constraint(equalTo: greenDotView2.topAnchor, constant: -10),
            infoLabel2.leadingAnchor.constraint(equalTo: greenDotView2.trailingAnchor, constant: 14),
            infoLabel2.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -26),
            greenDotView3.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 27),
            greenDotView3.topAnchor.constraint(equalTo: greenDotView2.bottomAnchor, constant: 95),
            greenDotView3.widthAnchor.constraint(equalToConstant: 8),
            greenDotView3.heightAnchor.constraint(equalToConstant: 8),
            infoLabel3.topAnchor.constraint(equalTo: greenDotView3.topAnchor, constant: -10),
            infoLabel3.leadingAnchor.constraint(equalTo: greenDotView3.trailingAnchor, constant: 14),
            infoLabel3.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -26),
            greenDotView4.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 27),
            greenDotView4.topAnchor.constraint(equalTo: greenDotView3.bottomAnchor, constant: 112),
            greenDotView4.widthAnchor.constraint(equalToConstant: 8),
            greenDotView4.heightAnchor.constraint(equalToConstant: 8),
            infoLabel4.topAnchor.constraint(equalTo: greenDotView4.topAnchor, constant: -10),
            infoLabel4.leadingAnchor.constraint(equalTo: greenDotView4.trailingAnchor, constant: 14),
            infoLabel4.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -26),
            bottomStackView.topAnchor.constraint(equalTo: infoLabel4.bottomAnchor, constant: 60),
            bottomStackView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor, constant: 0),
            selectionButton.widthAnchor.constraint(equalToConstant: 15),
            selectionButton.heightAnchor.constraint(equalToConstant: 15),
            enableButton.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 18),
            enableButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -26),
            enableButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -20),
            enableButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 20),
            enableButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
    }
    
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated:true)
    }
    
    // MARK: Button Actions :-
    @objc private func enableButtonTapped() {
        if self.enableButton.isSelected {
//            if SaveUserDefaultsData.WalletPassword.isEmpty {
//                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletPasscodeVC") as! MyWalletPasscodeVC
//                self.navigationController?.pushViewController(vc, animated: true)
//            }else {
//                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletPasscodeVC") as! MyWalletPasscodeVC
//                vc.isEnterPin = true
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            let vc = NewPasswordVC()
            vc.isGoingWallet = true
            vc.isVerifyPassword = true
            navigationController!.pushViewController(vc, animated: true)
            SSKPreferences.areWalletEnabled = true
        }
    }
    
    @objc private func selectionButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.enableButton.isSelected = self.selectionButton.isSelected
        if self.enableButton.isSelected {
            self.enableButton.backgroundColor = Colors.bothGreenColor
        } else {
            self.enableButton.backgroundColor = Colors.cellGroundColor2
        }
    }
   
}

extension UILabel {
    var spacing: CGFloat {
        get {return 0}
        set {
            let textAlignment = self.textAlignment
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = newValue
            let attributedString = NSAttributedString(string: self.text ?? "", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            self.attributedText = attributedString
            self.textAlignment = textAlignment
        }
    }
}


public extension String {
    func setColor(_ color: UIColor, ofSubstring substring: String) -> NSMutableAttributedString {
        let range = (self as NSString).range(of: substring)
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return attributedString
    }
}
