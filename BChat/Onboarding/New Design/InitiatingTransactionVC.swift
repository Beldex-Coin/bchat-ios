// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class InitiatingTransactionVC: BaseVC {
    
    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.smallBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = Colors.borderColorNew.cgColor
        return stackView
    }()
    private lazy var circleView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.confirmSendingViewBackgroundColor
        stackView.layer.cornerRadius = 35
        return stackView
    }()
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_initiating_transaction")
        result.set(.width, to: 42)
        result.set(.height, to: 42)
        result.layer.masksToBounds = true
        return result
    }()
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Initiating Transaction.."
        return result
    }()
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.font = Fonts.OpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Please don’t close the window or attend calls or navigate to another app until the transaction gets initiated"
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.backGroundColorWithAlpha
        let darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(backGroundView)
        backGroundView.addSubViews(circleView, titleLabel, discriptionLabel)
        circleView.addSubview(iconView)
        
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            circleView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 26),
            circleView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            circleView.heightAnchor.constraint(equalToConstant: 70),
            circleView.widthAnchor.constraint(equalToConstant: 70),
            iconView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 45),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -45),
            discriptionLabel.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -26),
        ])
        
        rotateIconView()
        
    }
    // iconView animation
    func rotateIconView() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.iconView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name("initiatingTransactionForWalletConnect"), object: nil)
    }
    
}
