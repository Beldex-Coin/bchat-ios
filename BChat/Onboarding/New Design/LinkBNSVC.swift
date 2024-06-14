// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatSnodeKit
import NVActivityIndicatorView

class LinkBNSVC: BaseVC {
    
    /// <#Description#>
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.viewBackgroundColorNew2
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColor.cgColor
        return stackView
    }()
    
    /// <#Description#>
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.boldOpenSans(ofSize: 20)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Link BNS"
        return result
    }()
    
    /// <#Description#>
    private lazy var bchatIdTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Your BChat ID"
        return result
    }()
    
    private lazy var bchatIdLabel: UILabel = {
        let result = PaddingLabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = Colors.cancelButtonBackgroundColor2
        result.paddingTop = 13
        result.paddingLeft = 16
        result.paddingRight = 16
        result.paddingBottom = 13
        result.numberOfLines = 0
        result.layer.cornerRadius = 10
        result.layer.masksToBounds = true
        return result
    }()
    
    private lazy var bnsNameTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.semiOpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "BNS Name"
        return result
    }()
    
    private lazy var bnsNameTextField: UITextField = {
        let result = UITextField()
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.placeholder = "Enter BNS name"
        result.backgroundColor = Colors.cancelButtonBackgroundColor2
        result.layer.cornerRadius = 16
        result.setLeftPaddingPoints(17)
        return result
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cancelButtonBackgroundColor2
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var verifyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Verify", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cancelButtonBackgroundColor2
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
        button.addTarget(self, action: #selector(verifyButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var linkButton: UIButton = {
        let button = UIButton()
        button.setTitle("Link", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cancelButtonBackgroundColor2
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.buttonDisableColor, for: .normal)
        button.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 7
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var loader: NVActivityIndicatorView = {
        let result = NVActivityIndicatorView(frame: CGRect.zero, type: .circleStrokeSpin, color: Colors.bothGreenColor, padding: nil)
        result.set(.width, to: 40)
        result.set(.height, to: 40)
        return result
    }()
    
    var isFromVerfied: Bool = false
    
    // MARK: - UIViewController life cycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        
        backGroundView.addSubViews(titleLabel, bchatIdTitleLabel, bchatIdLabel, bnsNameTitleLabel, bnsNameTextField, buttonStackView, linkButton)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(verifyButton)
        
        bchatIdLabel.text = "\(getUserHexEncodedPublicKey())"
        bnsNameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            bchatIdTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            bchatIdTitleLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 25),
            
            bchatIdLabel.topAnchor.constraint(equalTo: bchatIdTitleLabel.bottomAnchor, constant: 6),
            bchatIdLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            bchatIdLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -15),
            
            bnsNameTitleLabel.topAnchor.constraint(equalTo: bchatIdLabel.bottomAnchor, constant: 13),
            bnsNameTitleLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 23),
            bnsNameTextField.topAnchor.constraint(equalTo: bnsNameTitleLabel.bottomAnchor, constant: 9),
            bnsNameTextField.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            bnsNameTextField.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -15),
            bnsNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            buttonStackView.topAnchor.constraint(equalTo: bnsNameTextField.bottomAnchor, constant: 23),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            
            linkButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 13),
            linkButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            linkButton.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            linkButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
            verifyButton.heightAnchor.constraint(equalToConstant: 52),
            linkButton.heightAnchor.constraint(equalToConstant: 52),
        ])
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(dismissLinkBNSTapped), name: .dismissLinkBNSPopUpNotification, object: nil)
        
        view.addSubview(loader)
        loader.autoCenterInSuperview()
        showLoader(false)
        
        verifyButtonUpdate(false)
    }
    
    /// <#Description#>
    /// - Parameter notification: <#notification description#>
    @objc func dismissLinkBNSTapped(notification: NSNotification) {
        self.dismiss(animated: true)
    }
    
    /// <#Description#>
    /// - Parameter sender: <#sender description#>
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    /// <#Description#>
    /// - Parameter sender: <#sender description#>
    @objc private func verifyButtonTapped(_ sender: UIButton) {
        showLoader(true)
        // No Border
        bnsNameTextField.layer.borderWidth = 0
        bnsNameTextField.layer.borderColor = UIColor.clear.cgColor
        bnsNameTextField.isUserInteractionEnabled = false
        
        guard let bnsUserName = bnsNameTextField.text else { return }
        let bnsName = bnsUserName.trimmingCharacters(in: .whitespaces)
        SnodeAPI.getBChatID(for: bnsName.lowercased()).done { bchatID in
            self.showLoader(false)
            self.startNewDM(with: bchatID)
            UserDefaults.standard.set(bnsName, forKey: Constants.bnsUserName)
        }.catch { error in
            self.showLoader(false)
            self.bnsNameTextField.isUserInteractionEnabled = true
//            if let error = error as? SnodeAPI.Error {
//                switch error {
//                    case .decryptionFailed, .hashingFailed, .validationFailed, .validationNone: break
//                    default: break
//                }
//            }            
            self.linkButton.backgroundColor = Colors.cellGroundColor2
            self.linkButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
            // Red
            self.bnsNameTextField.layer.borderWidth = 1
            self.bnsNameTextField.layer.borderColor = Colors.bothRedColor.cgColor
            
//            self.verifyButtonUpdate(false)
        }
    }
    
    /// <#Description#>
    /// - Parameter sender: <#sender description#>
    @objc private func linkButtonTapped(_ sender: UIButton) {
        if isFromVerfied {
            let vc = BNSLinkSuccessVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    /// Description
    /// - Parameter bchatID: <#bchatID description#>
    private func startNewDM(with bchatID: String) {
        if bchatIdLabel.text == bchatID {
            isFromVerfied = true
            // link button enable color
            linkButton.backgroundColor = Colors.bothGreenColor
            linkButton.setTitleColor(Colors.bothWhiteColor, for: .normal)
            
            // Verify Button Border & White Title Color
            verifyButton.layer.borderWidth = 1
            verifyButton.layer.borderColor = Colors.bothGreenColor.cgColor
            verifyButton.setTitleColor(Colors.titleColor6, for: .normal)
            verifyButton.setTitle("Verify", for: .normal)
            
            // Verify Button Image & Green Title
            verifyButton.setTitleColor(Colors.bothGreenColor, for: .normal)
            verifyButton.setTitle("Verified", for: .normal)
            let image = UIImage(named: "ic_verified_new")?.scaled(to: CGSize(width: 14.42, height: 13.93))
            verifyButton.setImage(image, for: .normal)
            verifyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0)
            verifyButton.semanticContentAttribute = .forceRightToLeft
            
            bnsNameTextField.textColor = Colors.bothGreenColor
            // Green
            bnsNameTextField.layer.borderWidth = 1
            bnsNameTextField.layer.borderColor = Colors.bothGreenColor.cgColor
            
            verifyButton.isUserInteractionEnabled = false
        } else {
            isFromVerfied = false
            
            linkButton.backgroundColor = Colors.cellGroundColor2
            linkButton.setTitleColor(Colors.buttonDisableColor, for: .normal)
            // Red
            bnsNameTextField.layer.borderWidth = 1
            bnsNameTextField.layer.borderColor = Colors.bothRedColor.cgColor
        }
    }
    
    /// <#Description#>
    /// - Parameter isEnabled: <#isEnabled description#>
    func verifyButtonUpdate(_ isEnabled: Bool) {
        verifyButton.isUserInteractionEnabled =  isEnabled
        self.verifyButton.layer.borderWidth = isEnabled ? 1 : 0
        self.verifyButton.layer.borderColor =  isEnabled ? Colors.bothGreenColor.cgColor : UIColor.clear.cgColor
        self.verifyButton.setTitleColor(isEnabled ? Colors.titleColor6 : Colors.cancelButtonTitleColor, for: .normal)
    }
    
    func showLoader(_ isShow: Bool) {
        loader.isHidden = !isShow
        view.isUserInteractionEnabled = !isShow
        if isShow {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
    }
}

extension LinkBNSVC: UITextFieldDelegate {
    /// <#Description#>
    /// - Parameters:
    ///   - textField: <#textField description#>
    ///   - range: <#range description#>
    ///   - string: <#string description#>
    /// - Returns: <#description#>
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        verifyButtonUpdate(newString.suffix(4).lowercased() == ".bdx")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
