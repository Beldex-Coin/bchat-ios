import UIKit
import SignalUtilitiesKit
import BChatUIKit
import BChatSnodeKit
import BChatMessagingKit

@objc(LKNukeDataModal)
final class NukeDataModal : Modal {
    
    // MARK: Components
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor2
        result.font = Fonts.boldOpenSans(ofSize: 16)
        result.text = NSLocalizedString("CLEAR_ALL_DATA", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    private lazy var titleLabel2: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bothGreenColor
        result.font = Fonts.boldOpenSans(ofSize: Values.smallFontSize)
        result.text = NSLocalizedString("Chat ID", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    private lazy var explanationLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleColor2
        result.font = Fonts.regularOpenSans(ofSize: 14)
        result.text = NSLocalizedString("CLEAR_ALL_DATA_CONFIRMATION_TEXT", comment: "")
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    private lazy var clearDataButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: 52)
        result.layer.cornerRadius = Values.buttonRadius
        result.backgroundColor = Colors.bothRedColor
        result.titleLabel!.font = Fonts.regularOpenSans(ofSize: 14)
        result.setTitleColor(Colors.bothWhiteColor, for: .normal)
        result.setTitle("Clear", for: UIControl.State.normal)
        result.addTarget(self, action: #selector(clearEntireAccount), for: .touchUpInside)
        return result
    }()
    
    private lazy var buttonStackView1: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ cancelButton, clearDataButton ])
        result.axis = .horizontal
        result.spacing = 8
        result.distribution = .fillEqually
        return result
    }()
    
    private lazy var deviceOnlyButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: Values.mediumButtonHeight)
        result.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            result.backgroundColor = Colors.buttonBackground
        }else {
            result.backgroundColor = UIColor.lightGray
        }
        result.titleLabel!.font = Fonts.regularOpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(Colors.text, for: .normal)
        result.setTitle(NSLocalizedString("No", comment: ""), for: .normal)
        result.addTarget(self, action: #selector(clearDeviceOnly), for: .touchUpInside)
        return result
    }()
    
    private lazy var entireAccountButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: Values.mediumButtonHeight)
        result.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            result.backgroundColor = Colors.destructive
        }
        result.backgroundColor = Colors.destructive
        result.titleLabel!.font = Fonts.regularOpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(isLightMode ? UIColor.white : UIColor.white, for: .normal)
        result.setTitle(NSLocalizedString("Yes", comment: ""), for: .normal)
        result.addTarget(self, action: #selector(clearEntireAccount), for: .touchUpInside)
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
        result.addSubview(buttonStackView1)
        buttonStackView1.pin(to: result)
        return result
    }()
    
    private lazy var contentStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ titleLabel, explanationLabel ])
        result.axis = .vertical
        result.spacing = Values.largeSpacing
        return result
    }()
    
    private lazy var mainStackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [ contentStackView, buttonStackViewContainer ])
        result.axis = .vertical
        result.spacing = Values.largeSpacing - Values.smallFontSize / 2
        return result
    }()
    
    // MARK: Lifecycle
    override func populateContentView() {
        contentView.addSubview(mainStackView)
        contentView.backgroundColor = Colors.smallBackGroundColor
        mainStackView.pin(.leading, to: .leading, of: contentView, withInset: 18)
        mainStackView.pin(.top, to: .top, of: contentView, withInset: Values.largeSpacing)
        contentView.pin(.trailing, to: .trailing, of: mainStackView, withInset: 18)
        contentView.pin(.bottom, to: .bottom, of: mainStackView, withInset: mainStackView.spacing)
    }
    
    // MARK: Interaction
    @objc private func clearAllData() {
        UIView.animate(withDuration: 0.25) {
            self.buttonStackView1.alpha = 0
            self.buttonStackView2.alpha = 1
        }
        UIView.transition(with: explanationLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.explanationLabel.text = NSLocalizedString("modal_clear_all_data_explanation_2", comment: "")
        }, completion: nil)
    }
    
    @objc private func clearDeviceOnly() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func clearEntireAccount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        WalletSharedData.sharedInstance.isCleardataStarting = true
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] _ in
            guard let strongSelf = self else { return }
            MessageSender.syncConfiguration(forceSyncNow: true).ensure(on: DispatchQueue.main) {
                strongSelf.dismiss(animated: true, completion: nil) // Dismiss the loader
                strongSelf.deleteAllWalletFiles()
                AppEnvironment.shared.notificationPresenter.clearAllNotifications()
                UserDefaults.removeAll() // Not done in the nuke data implementation as unlinking requires this to happen later
                General.Cache.cachedEncodedPublicKey.mutate { $0 = nil } // Remove the cached key so it gets re-cached on next access
                NotificationCenter.default.post(name: .dataNukeRequested, object: nil)
            }.retainUntilComplete()
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
