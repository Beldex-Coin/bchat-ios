// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class WalletSendNewVC: UIViewController {
    
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        stackView.layer.borderColor = Colors.greenColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    private lazy var titleOfTotalBalanceLabel: UILabel = {
        let result = UILabel()
        result.text = "Total Balance"
        result.textColor = UIColor.lightGray
        result.font = Fonts.boldOpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var beldexLogoImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_Newcopy", in: Bundle.main, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        return imageView
    }()
    
    private lazy var beldexBalanceLabel: UILabel = {
        let result = UILabel()
        result.text = "3.333333"
        result.textColor = .white
        result.font = Fonts.boldOpenSans(ofSize: 24)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var middleView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.setTitleColor(UIColor(hex: 0x6E6E7C), for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 18)
//        button.addTarget(self, action: #selector(letsBChatButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Send"
        
        view.addSubViews(topView)
        topView.addSubview(titleOfTotalBalanceLabel)
        topView.addSubview(beldexLogoImg)
        topView.addSubview(beldexBalanceLabel)
        
        view.addSubview(middleView)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
//            topView.heightAnchor.constraint(equalToConstant: 100),
            
            titleOfTotalBalanceLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20),
            titleOfTotalBalanceLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
//            titleOfTotalBalanceLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -18),
            
            beldexLogoImg.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            beldexLogoImg.widthAnchor.constraint(equalToConstant: 18),
            beldexLogoImg.heightAnchor.constraint(equalToConstant: 18),
            beldexLogoImg.topAnchor.constraint(equalTo: titleOfTotalBalanceLabel.bottomAnchor, constant: 10),
//            beldexLogoImg.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -18),
            
            beldexBalanceLabel.leadingAnchor.constraint(equalTo: beldexLogoImg.trailingAnchor, constant: 10),
            beldexBalanceLabel.centerYAnchor.constraint(equalTo: beldexLogoImg.centerYAnchor),
            beldexBalanceLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -14),
            beldexBalanceLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -18),
            
        ])
        
        NSLayoutConstraint.activate([
            middleView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 18),
            middleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            middleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
        
        ])
        
        
        NSLayoutConstraint.activate([
            sendButton.topAnchor.constraint(equalTo: middleView.bottomAnchor, constant: 44),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            sendButton.heightAnchor.constraint(equalToConstant: 58),
            sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
        ])
        
        
        
        
        
    }
    

    
    // MARK: - Navigation

    
    
    
    
}
