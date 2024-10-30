// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit

class CustomGalleryVC: BaseVC {
    
    private lazy var outerBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.borderColor = Colors.borderColor.cgColor
        stackView.layer.borderWidth = 1
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    private lazy var innerProfileView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x14141E)
        stackView.layer.cornerRadius = 16
//        stackView.layer.borderColor = UIColor(red: 0, green: 0.742, blue: 0.252, alpha: 1).cgColor
//        stackView.layer.borderWidth = 1
        return stackView
    }()
  
    private lazy var imageView: UIImageView = {
        let stackView = UIImageView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.text = "Move and Scale"
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "X"), for: .normal)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    private lazy var changeImageButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Change image", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(changeImageButtonAction), for: UIControl.Event.touchUpInside)
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.setTitleColor(.lightGray, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var saveButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Save", comment: ""), for: UIControl.State.normal)
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        result.addTarget(self, action: #selector(saveButtonAction), for: UIControl.Event.touchUpInside)
        result.layer.cornerRadius = 16
        result.backgroundColor = Colors.bothGreenColor
        result.setTitleColor(UIColor.white, for: .normal)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    private lazy var buttonStackView1: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ changeImageButton, saveButton ])
        result.axis = .horizontal
        result.spacing = 15
        result.distribution = .fillEqually
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x11111A)
        
        view.addSubview(outerBackgroundView)
        outerBackgroundView.addSubview(titleLabel)
        outerBackgroundView.addSubview(closeButton)
        outerBackgroundView.addSubview(innerProfileView)
        outerBackgroundView.addSubview(buttonStackView1)
        innerProfileView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            outerBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            outerBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            outerBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            outerBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: outerBackgroundView.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: outerBackgroundView.centerXAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -10),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            innerProfileView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 23),
            innerProfileView.heightAnchor.constraint(equalToConstant: 300),
            innerProfileView.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 33),
            innerProfileView.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -33),
            
            imageView.leadingAnchor.constraint(equalTo: innerProfileView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: innerProfileView.trailingAnchor, constant: -0),
            imageView.topAnchor.constraint(equalTo: innerProfileView.topAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: innerProfileView.bottomAnchor, constant: -0),
            
            buttonStackView1.heightAnchor.constraint(equalToConstant: 52),
            buttonStackView1.topAnchor.constraint(equalTo: innerProfileView.bottomAnchor, constant: 25),
            buttonStackView1.trailingAnchor.constraint(equalTo: outerBackgroundView.trailingAnchor, constant: -20),
            buttonStackView1.leadingAnchor.constraint(equalTo: outerBackgroundView.leadingAnchor, constant: 20),
            buttonStackView1.bottomAnchor.constraint(equalTo: outerBackgroundView.bottomAnchor, constant: -25),
            
            
        ])
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeImageButton.layer.cornerRadius = changeImageButton.frame.height / 2
        saveButton.layer.cornerRadius = saveButton.frame.height / 2
        imageView.layer.cornerRadius = imageView.frame.height / 2
    }
    

    
    // MARK: - Navigation

    
    @objc func closeTapped(){
        
    }
    
    @objc func changeImageButtonAction(){
        
    }
    
    @objc func saveButtonAction(){
        
    }
    

}
