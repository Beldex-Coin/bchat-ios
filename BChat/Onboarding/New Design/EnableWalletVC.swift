// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class EnableWalletVC: BaseVC {
    
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor(hex: 0x24242F).cgColor
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
        result.textColor = UIColor(hex: 0xFFFFFF)
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
        result.textColor = UIColor(hex: 0xFFFFFF)
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
        result.textColor = UIColor(hex: 0xFFFFFF)
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
        result.textColor = UIColor(hex: 0xFFFFFF)
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
        result.textColor = UIColor(hex: 0xFFFFFF)
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
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 15)
        button.setTitleColor(UIColor(hex: 0x6C6C78), for: .normal)
        button.setTitleColor(UIColor(hex: 0xFFFFFF), for: .selected)
        button.addTarget(self, action: #selector(enableButtonTapped), for: .touchUpInside)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
        
        
        view.addSubview(backGroundView)
        backGroundView.addSubViews(greenDotView1, infoLabel1, greenDotView2, infoLabel2, greenDotView3, infoLabel3, greenDotView4, infoLabel4, bottomStackView)
        bottomStackView.addArrangedSubview(confirmationLabel)
        bottomStackView.addArrangedSubview(selectionButton)
        backGroundView.addSubview(enableButton)
        self.enableButton.isSelected = false
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
            greenDotView3.topAnchor.constraint(equalTo: greenDotView2.bottomAnchor, constant: 112),
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
    
    
    // MARK: Button Actions :-
    @objc private func enableButtonTapped() {
        if self.enableButton.isSelected {
            let vc = SyncInfoPopUpVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc private func selectionButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.enableButton.isSelected = self.selectionButton.isSelected
        if self.enableButton.isSelected {
            self.enableButton.backgroundColor = UIColor(hex: 0x00BD40)
        } else {
            self.enableButton.backgroundColor = UIColor(hex: 0x1C1C26)
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