import UIKit
import BChatUIKit
import BChatSnodeKit
import BChatMessagingKit

@objc(LKNukeDataModal)
final class NukeDataModal : Modal {
    
    // MARK: Components
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.boldOpenSans(ofSize: Values.mediumFontSize)
        result.text = NSLocalizedString("Clear All Data", comment: "")
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    private lazy var titleLabel2: UILabel = {
        let result = UILabel()
        result.textColor = Colors.bchat_button_clr
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
        result.text = NSLocalizedString("This will clear all your BChat data from device.", comment: "")
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
    
    private lazy var deviceOnlyButton: UIButton = {
        let result = UIButton()
        result.set(.height, to: Values.mediumButtonHeight)
        result.layer.cornerRadius = Modal.buttonCornerRadius
        if isDarkMode {
            result.backgroundColor = Colors.buttonBackground
        }else {
            result.backgroundColor = UIColor.lightGray
        }
//        result.backgroundColor = Colors.buttonBackground
        result.titleLabel!.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        result.setTitleColor(Colors.text, for: UIControl.State.normal)
        result.setTitle(NSLocalizedString("No", comment: ""), for: UIControl.State.normal)
        result.addTarget(self, action: #selector(clearDeviceOnly), for: UIControl.Event.touchUpInside)
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
        mainStackView.pin(.leading, to: .leading, of: contentView, withInset: Values.largeSpacing)
        mainStackView.pin(.top, to: .top, of: contentView, withInset: Values.largeSpacing)
        contentView.pin(.trailing, to: .trailing, of: mainStackView, withInset: Values.largeSpacing)
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
        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { [weak self] _ in
            MessageSender.syncConfiguration(forceSyncNow: true).ensure(on: DispatchQueue.main) {
                self?.dismiss(animated: true, completion: nil) // Dismiss the loader
                UserDefaults.removeAll() // Not done in the nuke data implementation as unlinking requires this to happen later
                General.Cache.cachedEncodedPublicKey.mutate { $0 = nil } // Remove the cached key so it gets re-cached on next access
                NotificationCenter.default.post(name: .dataNukeRequested, object: nil)
            }.retainUntilComplete()
        }
    }
}
