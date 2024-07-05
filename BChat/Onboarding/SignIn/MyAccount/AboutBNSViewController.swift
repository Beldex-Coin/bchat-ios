// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit



class AboutBNSViewController: BaseVC {

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
        result.textColor = Colors.titleColor3
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .clear
        result.isEditable = false
        result.isSelectable = false
        return result
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.setUpScreenBackgroundColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "About BNS"
        
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
        
        aboutDetailsLabel.attributedText = createAttributedString()
    }
    
    
    
    func createAttributedString() -> NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.boldOpenSans(ofSize: 16),
            .foregroundColor: Colors.titleColor3
        ]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.OpenSans(ofSize: 16),
            .foregroundColor: Colors.titleColor3
        ]
        
        let attributedString = NSMutableAttributedString()
        
        let title = NSAttributedString(string: "BNS: Your Decentralized Identity in the Beldex Ecosystem\n\n", attributes: titleAttributes)
        let subtitle = NSAttributedString(string: "BNS (Beldex Name Service) is your gateway to a seamless experience within the Beldex ecosystem. With BNS, you can create a unique, easy-to-remember name that links to your various Beldex identities.\n\n", attributes: normalAttributes)
        let benefitsTitle = NSAttributedString(string: "Key Benefits:\n\n", attributes: titleAttributes)
        let benefits = NSAttributedString(string: """
            \u{2022}  Unified Identity: Connect your BChat ID, Beldex Wallet Address, and BelNet ID to a single BNS name. This simplifies your interactions across the Beldex ecosystem.\n
            \u{2022}  Ease of Use: Say goodbye to complicated alphanumeric strings. With your BNS name, messaging and transactions become straightforward and user-friendly.\n
            \u{2022}  Badge of Trust: Link your BChat ID to your BNS name and complete the verification process to earn a BNS badge. This badge adds a layer of trust and recognition within the community.\n\n
            """, attributes: normalAttributes)
        let pricingTitle = NSAttributedString(string: "Pricing: ", attributes: titleAttributes)
        let pricing1 = NSAttributedString(string: "Users can register their BNS names for 1, 2, 5, and 10 years for as low as ", attributes: normalAttributes)
        let pricing2 = NSAttributedString(string: "650 BDX, 1000 BDX, 2000 BDX, and 4000 BDX", attributes: titleAttributes)
        let pricing3 = NSAttributedString(string: "respectively.\n\n", attributes: normalAttributes)
        let privacyTitle = NSAttributedString(string: "Using BNS names enhances your privacy, security, and convenience. Whether you’re sending a message, making a transaction, or using decentralized services, your BNS name ensures a consistent and simplified experience.\n\n", attributes: normalAttributes)
        let getStarted = NSAttributedString(string: "Get started with your BNS name today and enjoy the benefits of a decentralized identity across all your Beldex services!", attributes: normalAttributes)
        
        attributedString.append(title)
        attributedString.append(subtitle)
        attributedString.append(benefitsTitle)
        attributedString.append(benefits)
        attributedString.append(pricingTitle)
        attributedString.append(pricing1)
        attributedString.append(pricing2)
        attributedString.append(pricing3)
        attributedString.append(privacyTitle)
        attributedString.append(getStarted)
        
        return attributedString
    }
    
    
}
