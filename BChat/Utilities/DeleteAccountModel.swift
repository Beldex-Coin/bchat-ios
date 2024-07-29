
import Foundation
import BChatSnodeKit

final class DeleteAccountModel : Modal {
    
    // MARK: Components
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor2//Colors.text
        result.font = Fonts.boldOpenSans(ofSize: 18)//Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        result.text = "Delete entire account"//NSLocalizedString("Delete Entire Account", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    private lazy var titleLabel2: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bchatButtonColor
        result.font = Fonts.boldOpenSans(ofSize: Values.smallFontSize)
        result.text = NSLocalizedString("Chat ID", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    private lazy var explanationLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor2//Colors.text.withAlphaComponent(Values.mediumOpacity)
        result.font = Fonts.OpenSans(ofSize: 14)//Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.text = "Are you sure you want to Permanently clear all data from the Beldex Network?"//NSLocalizedString("You're initiating an account deletion. Upon initiation, your account will be deleted.However if you change your mind, you can still restore your account using your recovery seed within 14 days.After 14 days, your account will be permanently deleted.", comment: "")
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    private lazy var clearDataButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: 46)
        result.layer.cornerRadius = 23//Modal.buttonCornerRadius
//        if isDarkMode {
//            result.backgroundColor = Colors.destructive
//        }
        result.backgroundColor = Colors.cancelButtonBackgroundColor//Colors.destructive
        result.titleLabel!.font = Fonts.boldOpenSans(ofSize: 16)//Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(Colors.bothRedColor, for: UIControl.State.normal)
        result.setTitle("Delete", for: UIControl.State.normal)
        result.addTarget(self, action: #selector(clearEntireAccount), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var buttonStackView1: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ cancelButton, clearDataButton ])
        result.axis = .horizontal
        result.spacing = Values.mediumSpacing
        result.distribution = .fillEqually
        return result
    }()
    
    // device Only
    private lazy var deviceOnlyButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: Values.mediumButtonHeight)
        result.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            result.backgroundColor = Colors.buttonBackground
        }else {
            result.backgroundColor = UIColor.lightGray
        }
        result.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(Colors.text, for: UIControl.State.normal)
        result.setTitle(NSLocalizedString("No", comment: ""), for: UIControl.State.normal)
        result.addTarget(self, action: #selector(clearDeviceOnly), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    // Entire Account Only
    private lazy var entireAccountButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: Values.mediumButtonHeight)
        result.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            result.backgroundColor = Colors.destructive
        }
        result.backgroundColor = Colors.destructive
        result.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(isLightMode ? UIColor.white : UIColor.white, for: UIControl.State.normal)
        result.setTitle(NSLocalizedString("Yes", comment: ""), for: UIControl.State.normal)
        result.addTarget(self, action: #selector(clearEntireAccount), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    private lazy var buttonStackView2: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ deviceOnlyButton, entireAccountButton ])
        result.axis = .horizontal
        result.spacing = Values.mediumSpacing
        result.distribution = .fillEqually
        result.alpha = 0
        return result
    }()
    
    private lazy var buttonStackViewContainer: UIView = {
        let result = UIView()
//        result.addSubview(buttonStackView2)
//        buttonStackView2.pin(to: result)
        result.addSubview(buttonStackView1)
        buttonStackView1.pin(to: result)
        return result
    }()
    
    private lazy var mainStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ titleLabel, explanationLabel, buttonStackViewContainer ])
        result.axis = .vertical
        result.spacing = Values.mediumSpacing
        return result
    }()
    
    // MARK: Lifecycle
    override func populateContentView() {
        contentView.addSubview(mainStackView)
        contentView.backgroundColor = Colors.smallBackGroundColor
        mainStackView.pin(.leading, to: .leading, of: contentView, withInset: Values.largeSpacing)
        mainStackView.pin(.top, to: .top, of: contentView, withInset: Values.largeSpacing)
        contentView.pin(.trailing, to: .trailing, of: mainStackView, withInset: Values.largeSpacing)
        contentView.pin(.bottom, to: .bottom, of: mainStackView, withInset: Values.largeSpacing)
    }
    
    // MARK: Interaction
    @objc private func clearAllData() {
        UIView.animate(withDuration: 0.25) {
            self.buttonStackView1.alpha = 0
            self.buttonStackView2.alpha = 1
        }
        UIView.transition(with: explanationLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.explanationLabel.text = NSLocalizedString("This will permanently Delete your account, are you sure?", comment: "")
        }, completion: nil)
    }
    
    @objc private func clearDeviceOnly() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func clearEntireAccount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        WalletSharedData.sharedInstance.isCleardataStarting = true
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] _ in
            SnodeAPI.clearAllData().done(on: DispatchQueue.main) { confirmations in
                self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                let potentiallyMaliciousSnodes = confirmations.compactMap { $0.value == false ? $0.key : nil }
                if potentiallyMaliciousSnodes.isEmpty {
                    General.Cache.cachedEncodedPublicKey.mutate { $0 = nil } // Remove the cached key so it gets re-cached on next access
                    UserDefaults.removeAll() // Not done in the nuke data implementation as unlinking requires this to happen later
                    NotificationCenter.default.post(name: .dataNukeRequested, object: nil)
                    self?.deleteAllWalletFiles()
                    AppEnvironment.shared.notificationPresenter.clearAllNotifications()
                } else {
                    let message: String
                    if potentiallyMaliciousSnodes.count == 1 {
                        message = String(format: NSLocalizedString("dialog_clear_all_data_deletion_failed_1", comment: ""), potentiallyMaliciousSnodes[0])
                    } else {
                        message = String(format: NSLocalizedString("dialog_clear_all_data_deletion_failed_2", comment: ""), String(potentiallyMaliciousSnodes.count), potentiallyMaliciousSnodes.joined(separator: ", "))
                    }
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                    self?.presentAlert(alert)
                }
            }.catch(on: DispatchQueue.main) { error in
                self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("BUTTON_OK", comment: ""), style: .default, handler: nil))
                self?.presentAlert(alert)
            }
                        
//            guard let strongSelf = self else { return }
//            MessageSender.syncConfiguration(forceSyncNow: true).ensure(on: DispatchQueue.main) {
//                strongSelf.dismiss(animated: true, completion: nil) // Dismiss the loader
//                strongSelf.deleteAllWalletFiles()
//                AppEnvironment.shared.notificationPresenter.clearAllNotifications()
//                UserDefaults.removeAll() // Not done in the nuke data implementation as unlinking requires this to happen later
//                General.Cache.cachedEncodedPublicKey.mutate { $0 = nil } // Remove the cached key so it gets re-cached on next access
//                NotificationCenter.default.post(name: .dataNukeRequested, object: nil)
//            }.retainUntilComplete()
        }
    }
    
    func deleteAllWalletFiles() {
        let username = SaveUserDefaultsData.NameForWallet
        let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = allPaths[0]
        let documentPath = documentDirectory + "/"
        let pathWithFileName = documentPath + username
        let pathWithFileKeys = documentPath + "\(username).keys"
        let pathWithFileAddress = documentPath + "\(username).address.txt"
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponentForFileName = url.appendingPathComponent("\(username)") {
            let filePath = pathComponentForFileName.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileName)")
            }
        }
        if let pathComponentForFileKeys = url.appendingPathComponent("\(username).keys") {
            let filePath = pathComponentForFileKeys.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileKeys)")
            }
        }
        if let pathComponentForFileAddress = url.appendingPathComponent("\(username).address.txt") {
            let filePath = pathComponentForFileAddress.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                try? FileManager.default.removeItem(atPath: "\(pathWithFileAddress)")
            }
        }
    }
    
}
