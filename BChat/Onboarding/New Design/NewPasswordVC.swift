// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit

class NewPasswordVC: BaseVC {
    
    
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_lock")
        result.set(.width, to: 120)
        result.set(.height, to: 120)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var bottomView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 28
        return stackView
    }()
    
    lazy var pinStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var firstPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        return result
    }()
    
    private lazy var secondPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        return result
    }()
    
    private lazy var thirdPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        return result
    }()
    
    private lazy var fourthPinView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 8
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        return result
    }()
    
    
    private lazy var pinLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var oneView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var twoView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var threeView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var fourView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var fiveView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var sixView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var sevenView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var eightView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var nineView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var zeroView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var clearView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 13
        return result
    }()
    
    private lazy var emptyView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.layer.cornerRadius = 13
        return result
    }()
    
    
    lazy var firstStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var secondStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var thirdStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    lazy var forthStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.distribution = .fillEqually
        result.spacing = 17
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    
    private lazy var oneButton: UIButton = {
        let button = UIButton()
        button.setTitle("1", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var twoButton: UIButton = {
        let button = UIButton()
        button.setTitle("2", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var threeButton: UIButton = {
        let button = UIButton()
        button.setTitle("3", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var fourButton: UIButton = {
        let button = UIButton()
        button.setTitle("4", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var fiveButton: UIButton = {
        let button = UIButton()
        button.setTitle("5", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var sixButton: UIButton = {
        let button = UIButton()
        button.setTitle("6", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var sevenButton: UIButton = {
        let button = UIButton()
        button.setTitle("7", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var eightButton: UIButton = {
        let button = UIButton()
        button.setTitle("8", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nineButton: UIButton = {
        let button = UIButton()
        button.setTitle("9", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var zeroButton: UIButton = {
        let button = UIButton()
        button.setTitle("0", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.layer.cornerRadius = 13
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 26)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearImageView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_clear")
        result.layer.masksToBounds = true
        result.contentMode = .center
        return result
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Create Password"
        
        self.pinLabel.text = "Enter your PIN"
        
        
        pinStackView.addArrangedSubview(firstPinView)
        pinStackView.addArrangedSubview(secondPinView)
        pinStackView.addArrangedSubview(thirdPinView)
        pinStackView.addArrangedSubview(fourthPinView)
        
        view.addSubview(iconView)
        view.addSubview(pinStackView)
        view.addSubview(pinLabel)
        view.addSubview(bottomView)
        view.addSubview(nextButton)
        
        firstStackView.addArrangedSubview(oneView)
        firstStackView.addArrangedSubview(twoView)
        firstStackView.addArrangedSubview(threeView)
        oneView.addSubview(oneButton)
        oneButton.pin(to: oneView)
        twoView.addSubview(twoButton)
        twoButton.pin(to: twoView)
        threeView.addSubview(threeButton)
        threeButton.pin(to: threeView)
        view.addSubViews(firstStackView)
        
        secondStackView.addArrangedSubview(fourView)
        secondStackView.addArrangedSubview(fiveView)
        secondStackView.addArrangedSubview(sixView)
        fourView.addSubview(fourButton)
        fourButton.pin(to: fourView)
        fiveView.addSubview(fiveButton)
        fiveButton.pin(to: fiveView)
        sixView.addSubview(sixButton)
        sixButton.pin(to: sixView)
        view.addSubViews(secondStackView)
        
        thirdStackView.addArrangedSubview(sevenView)
        thirdStackView.addArrangedSubview(eightView)
        thirdStackView.addArrangedSubview(nineView)
        sevenView.addSubview(sevenButton)
        sevenButton.pin(to: sevenView)
        eightView.addSubview(eightButton)
        eightButton.pin(to: eightView)
        nineView.addSubview(nineButton)
        nineButton.pin(to: nineView)
        view.addSubViews(thirdStackView)
        
        forthStackView.addArrangedSubview(emptyView)
        forthStackView.addArrangedSubview(zeroView)
        forthStackView.addArrangedSubview(clearView)
        zeroView.addSubview(zeroButton)
        zeroButton.pin(to: zeroView)
        clearView.addSubview(clearButton)
        clearButton.pin(to: clearView)
        clearView.addSubview(clearImageView)
        clearImageView.pin(to: clearView)
        view.addSubViews(forthStackView)
        
        
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pinStackView.bottomAnchor.constraint(equalTo: pinLabel.topAnchor, constant: -16),
            pinStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinStackView.heightAnchor.constraint(equalToConstant: 56),
            firstPinView.widthAnchor.constraint(equalToConstant: 56),
//            pinStackView.widthAnchor.constraint(equalToConstant: 200),
            
            pinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            pinLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            pinLabel.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -26),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            bottomView.heightAnchor.constraint(equalToConstant: view.frame.height*0.57),
            
            
            firstStackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 40),
            firstStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            firstStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            oneView.heightAnchor.constraint(equalToConstant: 60),
            
            secondStackView.topAnchor.constraint(equalTo: firstStackView.bottomAnchor, constant: 25),
            secondStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            secondStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            fourView.heightAnchor.constraint(equalToConstant: 60),
            
            thirdStackView.topAnchor.constraint(equalTo: secondStackView.bottomAnchor, constant: 25),
            thirdStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            thirdStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            sevenView.heightAnchor.constraint(equalToConstant: 60),
            
            forthStackView.topAnchor.constraint(equalTo: thirdStackView.bottomAnchor, constant: 25),
            forthStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            forthStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            zeroView.heightAnchor.constraint(equalToConstant: 60),
            
            
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            nextButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
        
    }
    

    
    
    
    
    // MARK: Button Actions :-
    @objc private func nextButtonTapped() {
        let vc = NewRestoreSeedVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
   

}
