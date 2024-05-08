// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit
import PromiseKit

class NewPasswordVC: BaseVC {
    
    
    
    var isGoingHome = false
    var isGoingNewRestoreSeedVC = false
    var isGoingWallet = false
    var isGoingSendBDX = false
    var isGoingBack = false
    var isGoingNewRecoverySeed = false
    var isGoingConversionVC = false
    
    var isCreatePassword = false
    var isVerifyPassword = false
    var isChangePassword = false
    
//    var isSendWalletVC = false
    var wallet: BDXWallet?
    var finalWalletAddress = ""
    var finalWalletAmount = ""
    
    
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_lock")
        result.set(.width, to: 120)
        result.set(.height, to: 120)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 18)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var bottomView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 28
        return stackView
    }()
    
    lazy var pinStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var firstPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.bothGreenColor.cgColor
        return result
    }()
    
    private lazy var secondPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.bothGreenColor.cgColor
        return result
    }()
    
    private lazy var thirdPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.bothGreenColor.cgColor
        return result
    }()
    
    private lazy var fourthPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = Colors.bothGreenColor.cgColor
        return result
    }()
    
    
    private lazy var pin1: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_star")
        result.set(.width, to: 14)
        result.set(.height, to: 14)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var pin2: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_star")
        result.set(.width, to: 14)
        result.set(.height, to: 14)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var pin3: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_star")
        result.set(.width, to: 14)
        result.set(.height, to: 14)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var pin4: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_star")
        result.set(.width, to: 14)
        result.set(.height, to: 14)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    
    private lazy var pinLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleNewColor
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var oneView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var twoView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var threeView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var fourView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var fiveView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var sixView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var sevenView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var eightView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var nineView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var zeroView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var clearView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cellGroundColor2
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var emptyView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 13
        return result
    }()
    
    
    lazy var firstStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var secondStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var thirdStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var forthStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    
    private lazy var oneButton: UIButton = {
        let button = UIButton()
        button.setTitle("1", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 1
        return button
    }()
    
    private lazy var twoButton: UIButton = {
        let button = UIButton()
        button.setTitle("2", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 2
        return button
    }()
    
    private lazy var threeButton: UIButton = {
        let button = UIButton()
        button.setTitle("3", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 3
        return button
    }()
    
    private lazy var fourButton: UIButton = {
        let button = UIButton()
        button.setTitle("4", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 4
        return button
    }()
    
    private lazy var fiveButton: UIButton = {
        let button = UIButton()
        button.setTitle("5", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 5
        return button
    }()
    
    private lazy var sixButton: UIButton = {
        let button = UIButton()
        button.setTitle("6", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 6
        return button
    }()
    
    private lazy var sevenButton: UIButton = {
        let button = UIButton()
        button.setTitle("7", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 7
        return button
    }()
    
    private lazy var eightButton: UIButton = {
        let button = UIButton()
        button.setTitle("8", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 8
        return button
    }()
    
    private lazy var nineButton: UIButton = {
        let button = UIButton()
        button.setTitle("9", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 9
        return button
    }()
    
    private lazy var zeroButton: UIButton = {
        let button = UIButton()
        button.setTitle("0", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.setTitleColor(Colors.titleColor3, for: .normal)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 0
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(passwordButtonTapped), for: .touchUpInside)
        button.tag = 10
        return button
    }()
    
    private lazy var clearImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_clear")
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    
    var passwordText = ""
    var confirmPasswordText = ""
    
    
    var isPasswordEnterFirstTime = false

    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Create Password"
        
        self.pinLabel.text = "Enter your PIN"
        
        if isCreatePassword {
            self.title = "Create Password"
            self.pinLabel.text = "Enter your PIN"
        }
        if isChangePassword {
            self.pinLabel.text = "Enter Old PIN"
        }
        
        if isVerifyPassword {
            self.title = "Verify PIN"
            self.pinLabel.text = "Enter your 4 digit PIN"
        }
        
        
        pinStackView.addArrangedSubview(firstPinView)
        pinStackView.addArrangedSubview(secondPinView)
        pinStackView.addArrangedSubview(thirdPinView)
        pinStackView.addArrangedSubview(fourthPinView)
        
        firstPinView.addSubview(pin1)
        secondPinView.addSubview(pin2)
        thirdPinView.addSubview(pin3)
        fourthPinView.addSubview(pin4)
        
        view.addSubview(iconView)
        view.addSubview(pinStackView)
        view.addSubview(pinLabel)
        view.addSubview(bottomView)
        view.addSubview(nextButton)
        
        firstStackView.addArrangedSubview(oneView)
        firstStackView.addArrangedSubview(twoView)
        firstStackView.addArrangedSubview(threeView)
        oneView.addSubview(oneButton)
        oneButton.pin(to: oneView)
        twoView.addSubview(twoButton)
        twoButton.pin(to: twoView)
        threeView.addSubview(threeButton)
        threeButton.pin(to: threeView)
        view.addSubViews(firstStackView)
        
        secondStackView.addArrangedSubview(fourView)
        secondStackView.addArrangedSubview(fiveView)
        secondStackView.addArrangedSubview(sixView)
        fourView.addSubview(fourButton)
        fourButton.pin(to: fourView)
        fiveView.addSubview(fiveButton)
        fiveButton.pin(to: fiveView)
        sixView.addSubview(sixButton)
        sixButton.pin(to: sixView)
        view.addSubViews(secondStackView)
        
        thirdStackView.addArrangedSubview(sevenView)
        thirdStackView.addArrangedSubview(eightView)
        thirdStackView.addArrangedSubview(nineView)
        sevenView.addSubview(sevenButton)
        sevenButton.pin(to: sevenView)
        eightView.addSubview(eightButton)
        eightButton.pin(to: eightView)
        nineView.addSubview(nineButton)
        nineButton.pin(to: nineView)
        view.addSubViews(thirdStackView)
        
        forthStackView.addArrangedSubview(emptyView)
        forthStackView.addArrangedSubview(zeroView)
        forthStackView.addArrangedSubview(clearView)
        zeroView.addSubview(zeroButton)
        zeroButton.pin(to: zeroView)
        clearView.addSubview(clearButton)
        clearButton.pin(to: clearView)
        clearView.addSubview(clearImageView)
        clearImageView.pin(to: clearView)
        view.addSubViews(forthStackView)
        
        pin1.isHidden = true
        pin2.isHidden = true
        pin3.isHidden = true
        pin4.isHidden = true
        
        firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
        secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
        thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
        
        
        nextButton.backgroundColor = Colors.cellGroundColor2
        nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pinStackView.bottomAnchor.constraint(equalTo: pinLabel.topAnchor, constant: -16),
            pinStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinStackView.heightAnchor.constraint(equalToConstant: 56),
            firstPinView.widthAnchor.constraint(equalToConstant: 56),
//            pinStackView.widthAnchor.constraint(equalToConstant: 200),
            
            pin1.centerXAnchor.constraint(equalTo: firstPinView.centerXAnchor),
            pin1.centerYAnchor.constraint(equalTo: firstPinView.centerYAnchor),
            pin2.centerXAnchor.constraint(equalTo: secondPinView.centerXAnchor),
            pin2.centerYAnchor.constraint(equalTo: secondPinView.centerYAnchor),
            pin3.centerXAnchor.constraint(equalTo: thirdPinView.centerXAnchor),
            pin3.centerYAnchor.constraint(equalTo: thirdPinView.centerYAnchor),
            pin4.centerXAnchor.constraint(equalTo: fourthPinView.centerXAnchor),
            pin4.centerYAnchor.constraint(equalTo: fourthPinView.centerYAnchor),
            
            pinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            pinLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            pinLabel.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -26),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomView.heightAnchor.constraint(equalToConstant: view.frame.height*0.57),
            
            
            firstStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 40),
            firstStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            firstStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            oneView.heightAnchor.constraint(equalToConstant: 60),
            
            secondStackView.topAnchor.constraint(equalTo: firstStackView.bottomAnchor, constant: 25),
            secondStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            secondStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            fourView.heightAnchor.constraint(equalToConstant: 60),
            
            thirdStackView.topAnchor.constraint(equalTo: secondStackView.bottomAnchor, constant: 25),
            thirdStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            thirdStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            sevenView.heightAnchor.constraint(equalToConstant: 60),
            
            forthStackView.topAnchor.constraint(equalTo: thirdStackView.bottomAnchor, constant: 25),
            forthStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            forthStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            zeroView.heightAnchor.constraint(equalToConstant: 60),
            
            
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            nextButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
        
    }
    
    
    // MARK: Button Actions :-
    @objc private func nextButtonTapped() {
        if passwordText.count == 4 {
//            self.pin1.isHidden = false
//            self.pin2.isHidden = false
//            self.pin3.isHidden = false
//            self.pin4.isHidden = false
            
            
            if isChangePassword {
                if passwordText == SaveUserDefaultsData.BChatPassword {
                    isChangePassword = false
                    self.pinLabel.text = "Enter New PIN"
                    passwordText = ""
                    self.pin1.isHidden = true
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    nextButton.backgroundColor = Colors.cellGroundColor2
                    nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
                    firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    return
                    
                } else {
                    isChangePassword = true
                    self.pinLabel.text = "Enter Old PIN"
                    _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message2) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                    })
                    passwordText = ""
                    self.pin1.isHidden = true
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    nextButton.backgroundColor = Colors.cellGroundColor2
                    nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
                    return
                }
                
            }
            
            
            
            if isCreatePassword {
                isPasswordEnterFirstTime = true
                self.pin1.isHidden = true
                self.pin2.isHidden = true
                self.pin3.isHidden = true
                self.pin4.isHidden = true
                self.pinLabel.text = "Re-Enter your PIN"
                nextButton.backgroundColor = Colors.cellGroundColor2
                nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
                firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                return
            }
            
            if isPasswordEnterFirstTime {
                if passwordText == confirmPasswordText {
                    SaveUserDefaultsData.BChatPassword = confirmPasswordText
                    SaveUserDefaultsData.WalletPassword = confirmPasswordText
                } else {
                    _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message2) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                    })
                    confirmPasswordText = ""
                    self.pin1.isHidden = true
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    nextButton.backgroundColor = Colors.cellGroundColor2
                    nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
                    return
                }
            }
            
            if isVerifyPassword {
                if passwordText == SaveUserDefaultsData.BChatPassword {
                    
                } else {
                    _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Enter_Pin_Message2) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {
                    })
                    passwordText = ""
                    self.pin1.isHidden = true
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    nextButton.backgroundColor = Colors.cellGroundColor2
                    nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
                    return
                }
            }
            
            
            
            if self.isGoingHome == true {
                UserDefaults.standard[.isUsingFullAPNs] = true
                TSAccountManager.sharedInstance().didRegister()
                let homeVC = HomeVC()
                navigationController!.setViewControllers([ homeVC ], animated: true)
                let syncTokensJob = SyncPushTokensJob(accountManager: AppEnvironment.shared.accountManager, preferences: Environment.shared.preferences)
                syncTokensJob.uploadOnlyIfStale = false
                let _: Promise<Void> = syncTokensJob.run()
            }
            
            if self.isGoingNewRestoreSeedVC == true {
                let vc = NewRestoreSeedVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if self.isGoingWallet == true {
                let vc = WalletHomeNewVC()
                self.navigationController!.pushViewController(vc, animated: true)
            }
            
            if self.isGoingSendBDX == true {
                if self.navigationController != nil{
                    let count = self.navigationController!.viewControllers.count
                    if count > 1
                    {
                        let VC = self.navigationController!.viewControllers[count-2] as! WalletSendNewVC
                        VC.wallet = self.wallet
                        VC.finalWalletAddress = self.finalWalletAddress
                        VC.finalWalletAmount = self.finalWalletAmount
                        VC.backAPI = true
                        self.navigationController?.popViewController(animated: true)
    //                    NotificationCenter.default.post(name: Notification.Name(rawValue: "plm"), object: nil)
                    }
                }
            }
            
            if self.isGoingConversionVC == true {
                if self.navigationController != nil{
                    let count = self.navigationController!.viewControllers.count
                    if count > 1
                    {
                        let VC = self.navigationController!.viewControllers[count-2] as! ConversationVC
                        VC.wallet = self.wallet
                        VC.finalWalletAddress = self.finalWalletAddress
                        VC.finalWalletAmount = self.finalWalletAmount
                        VC.backAPI = true
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            
            if self.isGoingBack == true {
                let vc = PINSuccessPopUp()
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }
            
            if self.isGoingNewRecoverySeed == true {
                let vc = NewRecoverySeedVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    @objc private func passwordButtonTapped(sender : UIButton) {
        enterPassword(tag: sender.tag)
    }
    
    func enterPassword(tag: Int) {
        nextButton.backgroundColor = Colors.cellGroundColor2
        nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
        if isPasswordEnterFirstTime {
            isCreatePassword = false
            if confirmPasswordText.count == 4 {
                self.pin1.isHidden = false
                self.pin2.isHidden = false
                self.pin3.isHidden = false
                self.pin4.isHidden = false
                firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
            }
            
            if confirmPasswordText.count == 4 && tag == 10 {
                nextButton.backgroundColor = Colors.cellGroundColor2
                nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
                confirmPasswordText.removeLast()
                if confirmPasswordText.count == 0 {
                    self.pin1.isHidden = true
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if confirmPasswordText.count == 1 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if confirmPasswordText.count == 2 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if confirmPasswordText.count == 3 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = false
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if confirmPasswordText.count == 4 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = false
                    self.pin4.isHidden = false
                    nextButton.backgroundColor = Colors.bothGreenColor
                    nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                }
                return
            }
            
            if confirmPasswordText.count >= 0 && confirmPasswordText.count < 4 {
                if tag == 10 && confirmPasswordText.count != 0 {
                    confirmPasswordText.removeLast()
                    if confirmPasswordText.count == 0 {
                        self.pin1.isHidden = true
                        self.pin2.isHidden = true
                        self.pin3.isHidden = true
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 1 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = true
                        self.pin3.isHidden = true
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 2 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = false
                        self.pin3.isHidden = true
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 3 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = false
                        self.pin3.isHidden = false
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 4 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = false
                        self.pin3.isHidden = false
                        self.pin4.isHidden = false
                        nextButton.backgroundColor = Colors.bothGreenColor
                        nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    }
                } else {
                    if tag == 10 && confirmPasswordText.count == 0 {
                        return
                    }
                    confirmPasswordText += String(tag)
                    if confirmPasswordText.count == 0 {
                        self.pin1.isHidden = true
                        self.pin2.isHidden = true
                        self.pin3.isHidden = true
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 1 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = true
                        self.pin3.isHidden = true
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 2 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = false
                        self.pin3.isHidden = true
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 3 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = false
                        self.pin3.isHidden = false
                        self.pin4.isHidden = true
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    }
                    if confirmPasswordText.count == 4 {
                        self.pin1.isHidden = false
                        self.pin2.isHidden = false
                        self.pin3.isHidden = false
                        self.pin4.isHidden = false
                        nextButton.backgroundColor = Colors.bothGreenColor
                        nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
                        firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                        fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    }
                    return
                }
                return
            }
        }
        
        
        
        
        
        if passwordText.count == 4 {
            self.pin1.isHidden = false
            self.pin2.isHidden = false
            self.pin3.isHidden = false
            self.pin4.isHidden = false
            nextButton.backgroundColor = Colors.bothGreenColor
            nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
            firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
            secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
            thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
            fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
            
        }
        
        if passwordText.count == 4 && tag == 10 {
            nextButton.backgroundColor = Colors.cellGroundColor2
            nextButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
            passwordText.removeLast()
            if passwordText.count == 0 {
                self.pin1.isHidden = true
                self.pin2.isHidden = true
                self.pin3.isHidden = true
                self.pin4.isHidden = true
                firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
            }
            if passwordText.count == 1 {
                self.pin1.isHidden = false
                self.pin2.isHidden = true
                self.pin3.isHidden = true
                self.pin4.isHidden = true
                firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
            }
            if passwordText.count == 2 {
                self.pin1.isHidden = false
                self.pin2.isHidden = false
                self.pin3.isHidden = true
                self.pin4.isHidden = true
                firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
            }
            if passwordText.count == 3 {
                self.pin1.isHidden = false
                self.pin2.isHidden = false
                self.pin3.isHidden = false
                self.pin4.isHidden = true
                firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
            }
            if passwordText.count == 4 {
                self.pin1.isHidden = false
                self.pin2.isHidden = false
                self.pin3.isHidden = false
                self.pin4.isHidden = false
                nextButton.backgroundColor = Colors.bothGreenColor
                nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
                firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
            }
            return
        }
        
        if passwordText.count >= 0 && passwordText.count < 4 {
            if tag == 10 && passwordText.count != 0 {
                passwordText.removeLast()
                if passwordText.count == 0 {
                    self.pin1.isHidden = true
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 1 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 2 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 3 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = false
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 4 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = false
                    self.pin4.isHidden = false
                    nextButton.backgroundColor = Colors.bothGreenColor
                    nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                }
            } else {
                if tag == 10 && passwordText.count == 0 {
                    return
                }
                passwordText += String(tag)
                if passwordText.count == 0 {
                    self.pin1.isHidden = true
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 1 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = true
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 2 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = true
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.borderColorNew.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 3 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = false
                    self.pin4.isHidden = true
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    fourthPinView.layer.borderColor = Colors.borderColorNew.cgColor
                }
                if passwordText.count == 4 {
                    self.pin1.isHidden = false
                    self.pin2.isHidden = false
                    self.pin3.isHidden = false
                    self.pin4.isHidden = false
                    nextButton.backgroundColor = Colors.bothGreenColor
                    nextButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
                    firstPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    secondPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    thirdPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                    fourthPinView.layer.borderColor = Colors.bothGreenColor.cgColor
                }
                
            }
            
        }
        
    }
   
    
    
    

}
