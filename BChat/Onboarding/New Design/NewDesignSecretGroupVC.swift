// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class NewDesignSecretGroupVC: BaseVC {
    
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create a Secret Group +", for: .normal)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 14)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Secret Group"
        
        
        view.addSubview(createButton)
        
        
        NSLayoutConstraint.activate([
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            createButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 28),
            createButton.heightAnchor.constraint(equalToConstant: 40),

        ])
        
        
    }
    

    
    
    
    // MARK: Button Actions :-
    @objc private func createButtonTapped() {
        
    }
    
}
