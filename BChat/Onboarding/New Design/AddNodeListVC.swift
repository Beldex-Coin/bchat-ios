// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit
import Alamofire

class AddNodeListVC: BaseVC {

    private lazy var backGroundView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor(hex: 0x111119)
        stackView.layer.cornerRadius = 20
         stackView.layer.borderWidth = 1
         stackView.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return stackView
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.boldOpenSans(ofSize: 18)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Add Node"
        return result
    }()
    
    
    
    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x00BD40)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x282836)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)
        button.setTitleColor(UIColor(hex: 0xACACAC), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .horizontal
        result.alignment = .center
        result.distribution = .fillEqually
        result.spacing = 12
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    
    lazy var topStackView: UIStackView = {
        let result: UIStackView = UIStackView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.axis = .vertical
        result.alignment = .fill
        result.distribution = .fillEqually
        result.spacing = 6
        result.isLayoutMarginsRelativeArrangement = true
        return result
    }()
    
    private lazy var nodeAddressTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 12
        result.setLeftPaddingPoints(20)
        result.attributedPlaceholder = NSAttributedString(
            string: "Node Address",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)]
        )
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return result
    }()
    
    private lazy var nodePortTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 12
        result.setLeftPaddingPoints(20)
        result.attributedPlaceholder = NSAttributedString(
            string: "Node Port",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0xA7A7BA)]
        )
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor(hex: 0x4B4B64).cgColor
        return result
    }()
    
    private lazy var nodeNameTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 12
        result.setLeftPaddingPoints(20)
        result.attributedPlaceholder = NSAttributedString(
            string: "Node Name (optional)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x77778B)]
        )
        return result
    }()
    
    private lazy var userNameTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 12
        result.setLeftPaddingPoints(20)
        result.attributedPlaceholder = NSAttributedString(
            string: "User Name (optional)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x77778B)]
        )
        return result
    }()
    
    private lazy var passwordTextField: UITextField = {
        let result = UITextField()
        result.textColor = UIColor(hex: 0xFFFFFF)
        result.font = Fonts.OpenSans(ofSize: 16)
        result.textAlignment = .left
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = UIColor(hex: 0x282836)
        result.layer.cornerRadius = 12
        result.setLeftPaddingPoints(20)
        result.attributedPlaceholder = NSAttributedString(
            string: "Password (optional)",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(hex: 0x77778B)]
        )
        return result
    }()
    
    
    
    private lazy var testButton: UIButton = {
        let button = UIButton()
        button.setTitle("Test", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hex: 0x1C1C26)
        button.titleLabel!.font = Fonts.boldOpenSans(ofSize: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: 0x00BD40).cgColor
        button.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var resultLabel: UILabel = {
        let result = UILabel()
        result.textColor = UIColor(hex: 0x00BD40)
        result.font = Fonts.boldOpenSans(ofSize: 12)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.text = "Success"
        return result
    }()
    
    lazy var resultImageView: UIImageView = {
       let result = UIImageView()
       result.image = UIImage(named: "ic_success_node")//ic_error_node
        result.set(.width, to: 11)
        result.set(.height, to: 11)
       result.layer.masksToBounds = true
       result.contentMode = .scaleAspectFit
       return result
   }()
    
    var testResultFlag = false
    
    //MAINNET
    var nodeArray = ["explorer.beldex.io:19091","mainnet.beldex.io:29095","publicnode1.rpcnode.stream:29095","publicnode2.rpcnode.stream:29095","publicnode3.rpcnode.stream:29095","publicnode4.rpcnode.stream:29095","publicnode5.rpcnode.stream:29095"]//["149.102.156.174:19095"]
    //TESTNET
//    var nodeArray = ["149.102.156.174:19095"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hexValue: 0x080812, a: 0.5)
        
        var darkBlur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        var blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        
        view.addSubview(backGroundView)
        backGroundView.addSubViews(titleLabel, topStackView, testButton, resultLabel, resultImageView, buttonStackView)
        topStackView.addArrangedSubview(nodeAddressTextField)
        topStackView.addArrangedSubview(nodePortTextField)
        topStackView.addArrangedSubview(nodeNameTextField)
        topStackView.addArrangedSubview(userNameTextField)
        topStackView.addArrangedSubview(passwordTextField)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(okButton)
        
        resultLabel.isHidden = true
        resultImageView.isHidden = true
        
        NSLayoutConstraint.activate([
//            backGroundView.heightAnchor.constraint(equalToConstant: 600),
            backGroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            
            titleLabel.topAnchor.constraint(equalTo: backGroundView.topAnchor, constant: 19),
            titleLabel.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor),
            
            
            nodePortTextField.heightAnchor.constraint(equalToConstant: 56),
            nodeNameTextField.heightAnchor.constraint(equalToConstant: 56),
            userNameTextField.heightAnchor.constraint(equalToConstant: 56),
            passwordTextField.heightAnchor.constraint(equalToConstant: 56),
            nodeAddressTextField.heightAnchor.constraint(equalToConstant: 56),
            
            
            topStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            topStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 22),
            topStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -22),
            topStackView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -66),
            
            
            testButton.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 26),
            testButton.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -16),
            testButton.heightAnchor.constraint(equalToConstant: 34),
            testButton.widthAnchor.constraint(equalToConstant: 102),
            
            resultLabel.leadingAnchor.constraint(equalTo: testButton.trailingAnchor, constant: 11),
            resultLabel.centerYAnchor.constraint(equalTo: testButton.centerYAnchor),
            
            resultImageView.leadingAnchor.constraint(equalTo: resultLabel.trailingAnchor, constant: 4.56),
            resultImageView.centerYAnchor.constraint(equalTo: resultLabel.centerYAnchor),
            
//            buttonStackView.topAnchor.constraint(equalTo: discriptionLabel.bottomAnchor, constant: 21),
            buttonStackView.leadingAnchor.constraint(equalTo: backGroundView.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: backGroundView.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: backGroundView.bottomAnchor, constant: -21),
            buttonStackView.heightAnchor.constraint(equalToConstant: 52),
            okButton.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.heightAnchor.constraint(equalToConstant: 52),
            
        ])
        
        
    }
    
    
    @objc private func testButtonTapped(_ sender: UIButton) {
        if (nodeAddressTextField.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Address", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (nodePortTextField.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Port", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let txtfldStr = nodeAddressTextField.text! + ":" + nodePortTextField.text!
            verifyNodeURI(host_port: txtfldStr)
        }
    }
    
    
    // Node validation cheking
    func verifyNodeURI(host_port:String) {
        let url = "http://" + host_port + "/json_rpc"
        let param = ["jsonrpc": "2.0", "id": "0", "method": "getlastblockheader"]
        Session.default.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
            .responseDecodable(of: ApiResponseType.self) { (response) in
                switch response.result {
                case .success(let responseObject):
                    // Process the responseObject here
                    if let timestamp = responseObject.result?.block_header?.timestamp, timestamp > 0 {
                        self.resultLabel.isHidden = false
                        self.resultImageView.isHidden = false
                        self.resultLabel.textColor = UIColor(hex: 0x00BD40)
                        self.resultLabel.text = "Success"
                        self.resultImageView.image = UIImage(named: "ic_success_node")
                        
                        self.testResultFlag = true
                    } else {
                        self.resultLabel.isHidden = false
                        self.resultImageView.isHidden = false
                        self.resultLabel.textColor = UIColor(hex: 0xFF3E3E)
                        self.resultLabel.text = "Connection Error"
                        self.resultImageView.image = UIImage(named: "ic_error_node")
                        
                        self.testResultFlag = false
                    }
                case .failure(let error):
                    // Handle the error here
                    print("Request failed with error: \(error)")
                }
            }
    }
    
    
    
    @objc private func okButtonTapped(_ sender: UIButton) {

        if (nodeAddressTextField.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Address", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (nodePortTextField.text == "") {
            let alert = UIAlertController(title: "", message: "Please Enter Node Port", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if self.testResultFlag == true {
                let txtfldStr = nodeAddressTextField.text! + ":" + nodePortTextField.text!
                if nodeArray.contains(txtfldStr){
                    let alert = UIAlertController(title: "", message: "This Node is already exists", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else{
                    verifyNodeURICheking(host_port: txtfldStr)
                }
            }else {
                self.showToastMsg(message: "Make sure you test the node before adding it", seconds: 1.0)
            }
        }
    }
    
    func verifyNodeURICheking(host_port:String) {
        let url = "http://" + host_port + "/json_rpc"
        let param = ["jsonrpc": "2.0", "id": "0", "method": "get_info"]
        let dataTask = Session.default.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil)
        dataTask.responseJSON { (response) in
            let json = response.value as? [String: AnyObject]
            let result = json?["result"] as? [String: AnyObject]
            let nettype = result?["nettype"] as! String
            if nettype == "testnet" {
                let alert = UIAlertController(title: "", message: "This Node is TestNet", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                
                    self.nodeArray.append(host_port)
                
                
                SaveUserDefaultsData.SaveLocalNodelist = self.nodeArray
                SaveUserDefaultsData.SelectedNode = self.nodeArray.last!
                
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            dataTask.cancel()
        }
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    
    
    

    

}