// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class MissedCallPopUp: BaseVC {
    
    private let caller: String
    
    @objc
    init(caller: String) {
        self.caller = caller
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder: NSCoder) {
        preconditionFailure("Use init(onCallEnabled:) instead.")
    }

    override init(nibName: String?, bundle: Bundle?) {
        preconditionFailure("Use init(onCallEnabled:) instead.")
    }
    
    
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
        result.image = UIImage(named: "ic_missedCall")
        result.set(.width, to: 58)
        result.set(.height, to: 58)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor3
        result.font = Fonts.extraBoldOpenSans(ofSize: 16)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Call Missed!"
        return result
    }()
    
    private lazy var discriptionLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor
        result.textAlignment = .center
        result.numberOfLines = 0
        result.font = Fonts.OpenSans(ofSize: 14)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Call Missed from because you needed to enable the ‘Voice and video calls’ permission in the privacy settings."
        return result
    }()
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.cancelButtonBackgroundColor2
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(Colors.titleColor3, for: .normal)
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
        backGroundView.addSubViews(iconView, titleLabel, discriptionLabel, okButton)
        
        let message = String(format: NSLocalizedString("modal_call_missed_tips_explanation", comment: ""), caller)
        discriptionLabel.text = message
                
        NSLayoutConstraint.activate([
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            iconView.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 25),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            discriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            discriptionLabel.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 17),
            discriptionLabel.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -17),
            discriptionLabel.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -21),
            okButton.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            okButton.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -22),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            okButton.widthAnchor.constraint(equalToConstant: 158),
        ])
        
    }
    
    
    @objc private func okButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

}
