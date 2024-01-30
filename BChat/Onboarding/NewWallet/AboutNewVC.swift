// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class AboutNewVC: UIViewController {

    private lazy var backgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    private lazy var aboutDetailsLabel: UITextView = {
        let result = UITextView()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20, options: [:])]
        let attributedString = NSMutableAttributedString(string: "BChat is a decentralized peer to peer messaging application built on top of the Beldex blockchain. BChat preserves your privacy as it doesn't collect or store your personal information. All you need to create a BChat account is the internet.\n\n\tWhen you create an account on BChat, a unique BChat ID and recovery phrase (seed key) are generated. The BChat ID is your public key which you can use to chat with other people on BChat.\n\n\tThe recovery phrase (seed key) is your private key which you can use to restore your account. Your messages are routed through the nodes on the Beldex network and are stored locally on your device. Your messages and their associated metadata are not stored anywhere on the blockchain.\n\n\tBChat is built and maintained by the Beldex foundation. It is open-source and censorship-free. Anybody can contribute to its development. The Beldex foundation is an organization building privacy-first applications for the decentralized web.\n\n\tBChat is Beldex's flagship product. The initial version of BChat will be a messenger that lets you send truly anonymous messages. Future versions of BChat may incorporate voice and video calls, and let users send and receive BDX, the native cryptocurrency of the Beldex network.\n\n\tThe Beldex Research Labs, the research wing of the Beldex foundation is studying the possibility of implementing zk-SNARKs (as an alternative to ring signatures) and data sharding on the Beldex network, which may render BChat several times faster than current decentralized applications and put it on track for global adoption.\n\n\tCredits:The Beldex network and BChat uses several protocols that were designed by the open-source projects Monero, Signal, and Session.",
        attributes: [.paragraphStyle: paragraphStyle])
        result.attributedText = attributedString
        result.textColor = .white
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .justified
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        result.isEditable = false
        result.isSelectable = false
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "About"
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(aboutDetailsLabel)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -0),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0),
            aboutDetailsLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            aboutDetailsLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            aboutDetailsLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10),
            aboutDetailsLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
        ])
    }
}
