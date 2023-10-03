
import Foundation
import BChatSnodeKit

final class DeleteAccountModel : Modal {
    
    // MARK: Components
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        result.text = NSLocalizedString("Delete Entire Account", comment: "")
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
        result.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        result.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.text = NSLocalizedString("You're initiating an account deletion. Upon initiation, your account will be deleted.However if you change your mind, you can still restore your account using your recovery seed within 14 days.After 14 days, your account will be permanently deleted.", comment: "")
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    private lazy var clearDataButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: Values.mediumButtonHeight)
        result.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            result.backgroundColor = Colors.destructive
        }
        result.backgroundColor = Colors.destructive
        result.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(isLightMode ? UIColor.white : UIColor.white, for: UIControl.State.normal)
        result.setTitle(NSLocalizedString("TXT_DELETE_TITLE", comment: ""), for: UIControl.State.normal)
        result.addTarget(self, action: #selector(clearAllData), for: UIControl.Event.touchUpInside)
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
        result.addSubview(buttonStackView2)
        buttonStackView2.pin(to: result)
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
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] _ in
            // Dismiss the loader on the main thread
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: {
                    // After the loader is dismissed, you can continue with your data clearing and other operations here
                    self?.clearUserData()
                })
            }
        }
    }
    func clearUserData() {
        // Clear user data, such as UserDefaults and cached data
        UserDefaults.removeAll() // Not done in the nuke data implementation as unlinking requires this to happen later
        General.Cache.cachedEncodedPublicKey.mutate { $0 = nil }
        // Notify that data nuking is requested
        NotificationCenter.default.post(name: .dataNukeRequested, object: nil)
        // 3. Initiate the configuration synchronization with proper error handling
        MessageSender.syncConfiguration(forceSyncNow: true).ensure(on: DispatchQueue.main) {
            // Handle successful synchronization if needed
            UserDefaults.removeAll()
            General.Cache.cachedEncodedPublicKey.mutate { $0 = nil }
            NotificationCenter.default.post(name: .dataNukeRequested, object: nil)
        }
        .catch { error in
            // Handle any errors that may occur during synchronization
            print("Error synchronizing configuration: \(error)")
        }
        .retainUntilComplete()
    }
}
