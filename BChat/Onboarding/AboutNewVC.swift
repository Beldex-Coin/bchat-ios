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
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("ABOUT_CONTENT", comment: ""),
        attributes: [.paragraphStyle: paragraphStyle])
        result.attributedText = attributedString
        result.textColor = Colors.aboutContentLabelColor
        result.font = Fonts.regularOpenSans(ofSize: 14)
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
        self.title = NSLocalizedString("SIDE_MENU_ABOUT", comment: "")
        
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
