// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class ProfileDetailVC: BaseVC {
    
    
    
    private lazy var mainBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor
        stackView.layer.cornerRadius = 20
        stackView.layer.borderColor = Colors.newBorderColor.cgColor
        stackView.layer.borderWidth = 1
        return stackView
    }()
    
    private lazy var messageButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("WRITE_A_MESSAGE", comment: ""), for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.regularOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(messageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @objc private func messageButtonTapped() {
        self.dismiss(animated: true)
    }
   

}
