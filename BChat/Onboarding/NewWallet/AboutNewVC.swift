// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class AboutNewVC: BaseVC {

    private lazy var backgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.viewBackgroundColorNew
        stackView.layer.cornerRadius = 28
        stackView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return stackView
    }()
    private lazy var aboutDetailsLabel: UITextView = {
        let result = UITextView()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20, options: [:])]
        let attributedString = NSMutableAttributedString(string: "BChat is a decentralized peer to peer messaging application built on top of the Beldex blockchain. BChat preserves your confidentiality as it doesn't collect or store your personal information such as your name, age, email ID, phone number, username, location, contacts, IP address, etc. All you need to create a BChat account is the internet.\n\nWhen you create an account on BChat, a unique BChat ID and recovery phrase (seed key) are generated. The BChat ID is your public key which you can use to chat with other people on BChat. Your BChat ID is also connected to a wallet address which is generated each time you create a new account.\n\nThe recovery key (seed key) is your private key which you can use to restore your account on any device. Your recovery key is similar to your password. Do not share it with anyone. Do not store a digital copy of it. Write it down on paper and keep it safe. If you lose your recovery key, you will lose access to your account.\n\nOn BChat, your messages are routed through the nodes on the Beldex network and are only stored locally on your device. Your messages and their associated metadata are not stored anywhere on the Beldex blockchain including the masternode storage servers.\n\nYou own your data. You can choose to delete your data at any time with a single click of a button. To clear your data, click the profile icon at the top right corner, select ‘My Account > Clear Data > Delete>Ok’ and it’s gone.\n\nBChat is built and maintained by the Beldex foundation. It is open-source and censorship-free. Anybody can contribute to its development. The Beldex foundation is an organization building confidential applications for the decentralized web. The products that are currently being researched and developed include BChat, BelNet (a decentralized VPN service), Beldex Browser (a decentralized ad-free browser), and the Beldex protocol (a protocol to anonymize the transactions of other blockchain assets)\n\nBChat is Beldex's flagship product. The initial version of BChat will be a messenger that lets you send truly anonymous messages. You can create secret and social groups. Secret groups allow a maximum of 100 participants, while social groups do not have an upper limit. Anyone can create a secret group but you can only add your BChat contacts to it. Social groups require a dedicated server that needs to be maintained by its creator. Future versions of BChat may incorporate voice and video calls, and let users send and receive BDX, the native cryptocurrency of the Beldex network. The “pay as you chat” feature will allow anyone to transfer BDX to their contacts right from their chatbox.\n\nThe Beldex Research Labs, the research wing of the Beldex foundation is researching the possibility of implementing zk-SNARKs (as an alternative to ring signatures) to increase the anonymity set and data sharding to improve scalability on the Beldex network, which may render BChat several times faster than current decentralized applications and put it on track for global adoption.\n\nCredits:\nThe Beldex network and BChat uses several protocols that were designed by the open-source projects Monero, Signal, and Session.",
        attributes: [.paragraphStyle: paragraphStyle])
        result.attributedText = attributedString
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.OpenSans(ofSize: 14)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        result.isEditable = false
        result.isSelectable = false
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = Colors.setUpScreenBackgroundColor
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
