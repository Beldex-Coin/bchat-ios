// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import NVActivityIndicatorView
import PromiseKit
import BChatUIKit

class NewSocialGroupVC: BaseVC {
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xEBEBEB)
        result.font = Fonts.boldOpenSans(ofSize: 22)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var uRLTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.placeholder = "Enter Group URL"
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 16
        return result
    }()
    
    private lazy var nameOuterView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        stackView.backgroundColor = UIColor(hex: 0x282836)
        return stackView
    }()
    
    private lazy var scannerImg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "icons8-qr_code") // Set the image if you have one
        imageView.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        return imageView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.titleLabel!.font = Fonts.OpenSans(ofSize: 18)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var topView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x1C1C26)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private lazy var groupURLTextField: UITextField = {
        let result = UITextField()
        result.attributedPlaceholder = NSAttributedString(string:"Enter Date", attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? 12 : 12)
        result.layer.borderColor = Colors.text.cgColor
        result.backgroundColor = UIColor(hex: 0x1C1C26)
//        result.set(.height, to: 60)
//        result.set(.width, to: 343)
        result.layer.cornerRadius = 16
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingViewLeft
        result.leftViewMode = .always
        // Create an UIImageView and set its image
        let imageView = UIImageView(image: UIImage(named: "ic_calendar"))
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Adjust the frame as needed
        imageView.contentMode = .scaleAspectFit // Set the content mode as needed
        
        // Add tap gesture recognizer to the imageView
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
//        imageView.isUserInteractionEnabled = true
//        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add some padding between the image and the text field
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        result.rightView = paddingView
        result.rightViewMode = .always
        
        // Set the rightView of the TextField to the created UIImageView
        result.rightView?.addSubview(imageView)
        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = UIColor(hex: 0x11111A)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Social group"
        self.titleLabel.text = "Join Social Group"
        
        view.addSubViews(titleLabel)
        view.addSubViews(topView)

        topView.addSubview(nameOuterView)
        topView.addSubview(nextButton)
        nameOuterView.addSubview(scannerImg)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            topView.heightAnchor.constraint(equalToConstant: 161)
        ])
        
        NSLayoutConstraint.activate([
            scannerImg.trailingAnchor.constraint(equalTo: nameOuterView.trailingAnchor, constant: 15)
        ])
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameOuterView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 18),
            nameOuterView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            nameOuterView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -18),
            nextButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 18),
            nextButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -18),
            nextButton.topAnchor.constraint(equalTo: nameOuterView.bottomAnchor, constant: 10),
            
            // Set equal heights for nameTextField and nextButton
            nameOuterView.heightAnchor.constraint(equalTo: nextButton.heightAnchor),
            nextButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -18),
        ])
        
        
    }
    

    
    // MARK: Button Actions :-
    @objc private func nextButtonTapped() {
        
    }
    
    
    
    
    

}
