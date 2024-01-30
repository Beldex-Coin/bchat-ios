// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit

class RegisterVC: BaseVC {
    
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 22)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var bChatLabel: UILabel = {
        let result = UILabel()
        result.text = "BChat ID"
        result.textColor = UIColor(hex: 0x00BD40)
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var bChatIdLabel: UILabel = {
        let result = UILabel()
        result.text = "328632bdskhj839ehdnd92dddid83993ndasoaksjhpifyaoajscqitp98wkjhaiuahhashf9ahfsdfhasdf.."
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var bChatInfoLabel: UILabel = {
        let result = UILabel()
        result.text = "Your BChat ID is like your username. You can share it with your friends to begin a conversation."
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var bottomView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var beldexLabel: UILabel = {
        let result = UILabel()
        result.text = "Beldex Address"
        result.textColor = UIColor(hex: 0x0085FF)
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var beldexIdLabel: UILabel = {
        let result = UILabel()
        result.text = "328632bdskhj839ehdnd92dddid83993ndasoaksjhpifyaoajscqitp98wkjhaiuahhashf9ahfsdfhasdf.."
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var beldexInfoLabel: UILabel = {
        let result = UILabel()
        result.text = "Your Beldex address is connected to your BChat ID. You can use this address to receive BDX."
        result.textColor = UIColor(hex: 0xA7A7BA)
        result.font = Fonts.OpenSans(ofSize: 12)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Register"
        self.titleLabel.text = "Hey Name, Welcome to BChat"
        
        view.addSubViews(titleLabel)
        view.addSubViews(continueButton)
        view.addSubViews(topView)
        view.addSubview(bChatInfoLabel)
        view.addSubViews(bottomView)
        view.addSubview(beldexInfoLabel)

        topView.addSubview(bChatLabel)
        topView.addSubview(bChatIdLabel)
        bottomView.addSubview(beldexLabel)
        bottomView.addSubview(beldexIdLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            continueButton.heightAnchor.constraint(equalToConstant: 58),

        ])
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bChatLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 17),
            bChatLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            bChatIdLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20),
            bChatIdLabel.topAnchor.constraint(equalTo: bChatLabel.bottomAnchor, constant: 7),
            bChatIdLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            bChatIdLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -18),
            bChatInfoLabel.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10),
            bChatInfoLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 16),
            bChatInfoLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -9),
        ])
        
        
        NSLayoutConstraint.activate([
            bottomView.topAnchor.constraint(equalTo: bChatInfoLabel.bottomAnchor, constant: 32),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            beldexLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 17),
            beldexLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 18),
            beldexIdLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -20),
            beldexIdLabel.topAnchor.constraint(equalTo: beldexLabel.bottomAnchor, constant: 7),
            beldexIdLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 18),
            beldexIdLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -18),
            beldexInfoLabel.topAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: 10),
            beldexInfoLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            beldexInfoLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -9),
        ])
        
    }
    


    // MARK: Button Actions :-
    @objc private func continueButtonTapped() {
        let vc = NewPasswordVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
   
}
