// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class WalletReceiveNewVC: UIViewController,UITextFieldDelegate {
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("SHARE_OPTION_NEW", comment: ""), for: .normal)
        let image = UIImage(named: "ic_shareNew")?.scaled(to: CGSize(width: 25.0, height: 25.0))
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white // Set the tint color to white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.greenColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var topBackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x11111A)
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    private lazy var beldexAddressBgView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = Colors.backgroundViewColor2
        return stackView
    }()
    private lazy var beldexAddressIDLabel: UILabel = {
        let result = UILabel()
        result.text = "bxdXXqFFk2QQWcqerE87fE5yHG5jggkNAAdxGBvQLGLg5h75ZeTAbAW31GhJPCW7kb8zagsoQ95HtfsfRnaWo49s35jrQyspZ"
        result.textColor = Colors.greenColor
        result.font = Fonts.OpenSans(ofSize: 13)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    private lazy var copyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.greenColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setImage(UIImage(named: "ic_copy_white2"), for: .normal)
        button.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var beldexAddressTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("BELDEX_ADDRESS", comment: "")
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var bdxAmountTextField: UITextField = {
        let result = UITextField()
        result.delegate = self
        result.translatesAutoresizingMaskIntoConstraints = false
        result.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("0.00000", comment: ""), attributes:[NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)])
        result.font = Fonts.OpenSans(ofSize: 16)
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        result.backgroundColor = UIColor(hex: 0x1C1C26)
        result.layer.cornerRadius = 10
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 21, height: result.frame.size.height))
        result.leftView = paddingView
        result.leftViewMode = .always
        result.layer.borderColor = UIColor.lightGray.cgColor
        result.layer.borderWidth = 0.5
        return result
    }()
    private lazy var bdxAmountTitleLabel: UILabel = {
        let result = UILabel()
        result.text = NSLocalizedString("ENTER_BDX_AMOUNT", comment: "")
        result.textColor = UIColor(hex: 0xACACAC)
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    private lazy var isFromQrCodebackgroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 12
        stackView.backgroundColor = Colors.backgroundViewColor2
        return stackView
    }()
    private lazy var qrCodeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hex: 0x1C1C26)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = "Receive"
        
        view.addSubview(topBackgroundView)
        topBackgroundView.addSubview(beldexAddressBgView)
        beldexAddressBgView.addSubview(beldexAddressIDLabel)
        topBackgroundView.addSubview(copyButton)
        topBackgroundView.addSubview(beldexAddressTitleLabel)
        topBackgroundView.addSubview(bdxAmountTextField)
        topBackgroundView.addSubview(bdxAmountTitleLabel)
        topBackgroundView.addSubview(isFromQrCodebackgroundView)
        isFromQrCodebackgroundView.addSubview(qrCodeImage)
        view.addSubview(shareButton)

        //This QR is Sample QR Code
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        qrCodeImage.image = qrCode
        
        NSLayoutConstraint.activate([
            topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            topBackgroundView.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -25),
            beldexAddressBgView.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -40),
            beldexAddressBgView.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 19),
            beldexAddressBgView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -19),
            beldexAddressIDLabel.topAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: 22),
            beldexAddressIDLabel.bottomAnchor.constraint(equalTo: beldexAddressBgView.bottomAnchor, constant: -22),
            beldexAddressIDLabel.leadingAnchor.constraint(equalTo: beldexAddressBgView.leadingAnchor, constant: 22),
            beldexAddressIDLabel.trailingAnchor.constraint(equalTo: beldexAddressBgView.trailingAnchor, constant: -22),
            copyButton.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -20),
            copyButton.widthAnchor.constraint(equalToConstant: 32),
            copyButton.heightAnchor.constraint(equalToConstant: 32),
            copyButton.bottomAnchor.constraint(equalTo: beldexAddressBgView.topAnchor, constant: -15),
            beldexAddressTitleLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 26),
            beldexAddressTitleLabel.centerYAnchor.constraint(equalTo: copyButton.centerYAnchor),
            beldexAddressTitleLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -7),
            bdxAmountTextField.bottomAnchor.constraint(equalTo: copyButton.topAnchor, constant: -20),
            bdxAmountTextField.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 19),
            bdxAmountTextField.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -19),
            bdxAmountTextField.heightAnchor.constraint(equalToConstant: 53),
            bdxAmountTitleLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 26),
            bdxAmountTitleLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -7),
            bdxAmountTitleLabel.bottomAnchor.constraint(equalTo: bdxAmountTextField.topAnchor, constant: -10),
            isFromQrCodebackgroundView.widthAnchor.constraint(equalToConstant: 190),
            isFromQrCodebackgroundView.heightAnchor.constraint(equalToConstant: 190),
            isFromQrCodebackgroundView.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor),
            isFromQrCodebackgroundView.bottomAnchor.constraint(equalTo: bdxAmountTitleLabel.topAnchor, constant: -35),
            isFromQrCodebackgroundView.centerYAnchor.constraint(equalTo: topBackgroundView.firstBaselineAnchor, constant: 25),
            qrCodeImage.topAnchor.constraint(equalTo: isFromQrCodebackgroundView.topAnchor, constant: 20),
            qrCodeImage.bottomAnchor.constraint(equalTo: isFromQrCodebackgroundView.bottomAnchor, constant: -20),
            qrCodeImage.leadingAnchor.constraint(equalTo: isFromQrCodebackgroundView.leadingAnchor, constant: 20),
            qrCodeImage.trailingAnchor.constraint(equalTo: isFromQrCodebackgroundView.trailingAnchor, constant: -20),
        ])
        NSLayoutConstraint.activate([
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            shareButton.heightAnchor.constraint(equalToConstant: 58),
        ])
        
    }
    

    
    // MARK: - Navigation

    @objc func shareButtonTapped(_ sender: UIButton) {
        let qrCode = QRCode.generate(for: getUserHexEncodedPublicKey(), hasBackground: true)
        let shareVC = UIActivityViewController(activityItems: [ qrCode ], applicationActivities: nil)
        self.navigationController!.present(shareVC, animated: true, completion: nil)
    }
    
    @objc func copyButtonTapped(_ sender: UIButton){
        
    }

}
