// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class WalletTransactionSuccessVC: BaseVC {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
         stackView.layer.borderWidth = 1
         stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_pinSuccess")
        result.set(.width, to: 118)
        result.set(.height, to: 118)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Transaction Successful!"
        return result
    }()
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(iconView, titleLabel, okButton)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            iconView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 0),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -17),
            okButton.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            okButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -24),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            okButton.widthAnchor.constraint(equalToConstant: 158),
        ])
    }
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        NotificationCenter.default.post(name: Notification.Name("transactionSuccessfulButtonTapped"), object: nil)
    }
    
}
