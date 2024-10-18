// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class SelectDateRangePopUpVC: BaseVC {
    
    private lazy var backgroundBlerView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let logoImage = isLightMode ? "ic_no_transactions_white" : "ic_backgroundBlerView"
        imageView.image = UIImage(named: logoImage, in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var selectDateRangePopUpbackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColor.cgColor
        return stackView
    }()
    
    lazy var selectDateRangeTitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = NSLocalizedString("Select Date Range", comment: "")
        return result
    }()
    
    private lazy var fromDateTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("From Date", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColor.cgColor
        result.layer.borderWidth = 1
        result.backgroundColor = Colors.cellGroundColor2
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = Values.buttonRadius
        // Left Image
        let leftImageView = UIImageView(image: UIImage(named: "ic_Calendar_green"))
        leftImageView.frame = CGRect(x: 15, y: 0, width: 20, height: 20)
        leftImageView.contentMode = .scaleAspectFit
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 20))
        leftPaddingView.addSubview(leftImageView)
        result.leftView = leftPaddingView
        result.leftViewMode = .always
        // Right Image
        let rightImageView = UIImageView(image: UIImage(named: "ic_fullCircle"))
        rightImageView.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        rightImageView.contentMode = .scaleAspectFit
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 8))
        rightPaddingView.addSubview(rightImageView)
        result.rightView = rightPaddingView
        result.rightViewMode = .always
        return result
    }()
    
    private lazy var toDateTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("To Date", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 14)
        result.layer.borderColor = Colors.borderColor.cgColor
        result.layer.borderWidth = 1
        result.backgroundColor = Colors.cellGroundColor2
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = Values.buttonRadius
        // Left Image
        let leftImageView = UIImageView(image: UIImage(named: "ic_Calendar_blue"))
        leftImageView.frame = CGRect(x: 15, y: 0, width: 20, height: 20)
        leftImageView.contentMode = .scaleAspectFit
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 20))
        leftPaddingView.addSubview(leftImageView)
        result.leftView = leftPaddingView
        result.leftViewMode = .always
        // Right Image
        let rightImageView = UIImageView(image: UIImage(named: "ic_Ellipse_New"))
        rightImageView.frame = CGRect(x: 0, y: 0, width: 8, height: 8)
        rightImageView.contentMode = .scaleAspectFit
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 8))
        rightPaddingView.addSubview(rightImageView)
        result.rightView = rightPaddingView
        result.rightViewMode = .always
        return result
    }()
    
    private lazy var cancelButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside) // Make sure the action is set properly
        result.backgroundColor = Colors.cancelButtonBackgroundColor2
        result.setTitleColor(Colors.cancelButtonTitleColor, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var okButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("OK", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(okButtonTapped), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.backgroundColor = Colors.greenColor
        result.setTitleColor(UIColor.white, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ cancelButton, okButton ])
        result.axis = .horizontal
        result.spacing = 15
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    // Example of adding a custom navigation bar
    private lazy var customNavigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear // Set your desired background color
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(backgroundBlerView)
        backgroundBlerView.addSubview(selectDateRangePopUpbackgroundView)
        selectDateRangePopUpbackgroundView.addSubview(selectDateRangeTitleLabel)
        selectDateRangePopUpbackgroundView.addSubview(fromDateTextField)
        selectDateRangePopUpbackgroundView.addSubview(toDateTextField)
        selectDateRangePopUpbackgroundView.addSubview(buttonStackView)
        
        NSLayoutConstraint.activate([
            backgroundBlerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundBlerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            backgroundBlerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backgroundBlerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            selectDateRangePopUpbackgroundView.leadingAnchor.constraint(equalTo: backgroundBlerView.leadingAnchor, constant: 22),
            selectDateRangePopUpbackgroundView.trailingAnchor.constraint(equalTo: backgroundBlerView.trailingAnchor, constant: -22),
            selectDateRangePopUpbackgroundView.centerYAnchor.constraint(equalTo: backgroundBlerView.centerYAnchor),
            selectDateRangePopUpbackgroundView.centerXAnchor.constraint(equalTo: backgroundBlerView.centerXAnchor),
            selectDateRangeTitleLabel.topAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.topAnchor, constant: 20),
            selectDateRangeTitleLabel.centerXAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.centerXAnchor),
            fromDateTextField.topAnchor.constraint(equalTo: selectDateRangeTitleLabel.bottomAnchor, constant: 20),
            fromDateTextField.heightAnchor.constraint(equalToConstant: 54),
            fromDateTextField.leadingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.leadingAnchor, constant: 21),
            fromDateTextField.trailingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.trailingAnchor, constant: -21),
            toDateTextField.topAnchor.constraint(equalTo: fromDateTextField.bottomAnchor, constant: 10),
            toDateTextField.heightAnchor.constraint(equalToConstant: 54),
            toDateTextField.leadingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.leadingAnchor, constant: 21),
            toDateTextField.trailingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.trailingAnchor, constant: -21),
            buttonStackView.topAnchor.constraint(equalTo: toDateTextField.bottomAnchor, constant: 16),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            buttonStackView.leadingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.leadingAnchor, constant: 21),
            buttonStackView.trailingAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.trailingAnchor, constant: -21),
            buttonStackView.bottomAnchor.constraint(equalTo: selectDateRangePopUpbackgroundView.bottomAnchor, constant: -25),
        ])
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Navigation
    @objc func cancelButtonTapped(_ sender: UIButton){
        
    }
    @objc func okButtonTapped(_ sender: UIButton){
        
    }
    
    
    
}
