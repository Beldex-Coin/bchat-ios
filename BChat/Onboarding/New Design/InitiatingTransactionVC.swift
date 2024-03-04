// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class InitiatingTransactionVC: BaseVC {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return stackView
    }()
    private lazy var circleView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x30303F)
        stackView.layer.cornerRadius = 35
        return stackView
    }()
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0x00BD40)
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Initiating Transaction.."
        return result
    }()
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Please don’t close the window or attend calls or negative to another app until the transaction gets initiated"
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.7)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(circleView, titleLabel, discriptionLabel)
        
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            circleView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 26),
            circleView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            circleView.heightAnchor.constraint(equalToConstant: 70),
            circleView.widthAnchor.constraint(equalToConstant: 70),
            titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 45),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -45),
            discriptionLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -26),
        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("initiatingTransactionForWalletConnect"), object: nil)
    }
    
}
