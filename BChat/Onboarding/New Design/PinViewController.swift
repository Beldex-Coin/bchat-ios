// Copyright © 2026 Beldex International Limited OU. All rights reserved.

import UIKit
import BChatUIKit
import BChatMessagingKit
import PromiseKit

public enum PinFlowStep {
    case enterOldPin
    case enterNewPin
    case confirmNewPin
    case createPin
    case confirmCreatePin
    case verifyPin
}

public enum CreatePinDestination {
    case restoreSeed
    case home
}

class PinViewController: BaseVC {
    
    // MARK: - UI elements
    
    private lazy var iconView: UIImageView = {
        let result = UIImageView()
        result.image = UIImage(named: "ic_lock")
        result.set(.width, to: 120)
        result.set(.height, to: 120)
        result.layer.masksToBounds = true
        result.contentMode = .scaleAspectFit
        return result
    }()
    
    private lazy var pinLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.titleNewColor
        result.font = Fonts.semiOpenSans(ofSize: 16)
        result.textAlignment = .center
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        return result
    }()
    
    private lazy var keypadView: UIView = {
        let stackView = UIView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = Colors.mainBackGroundColor2
        stackView.layer.cornerRadius = 28
        return stackView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.layer.cornerRadius = Values.buttonRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.bothGreenColor
        button.titleLabel!.font = Fonts.regularOpenSans(ofSize: 16)
        button.setTitleColor(Colors.bothWhiteColor, for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private var pinLabels: [UILabel] = []
    private let pinLength = 4
    
    private var currentPin = ""
    private var firstPinEntry: String?
    public var flowStep: PinFlowStep = .verifyPin
    public var createPinDestination: CreatePinDestination = .restoreSeed

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPinFields()
        setupKeypad()
        configureFlow()
    }
    
    // MARK: - Setup View
    
    private func setupView() {
        view.backgroundColor = Colors.cancelButtonBackgroundColor
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        view.addSubview(iconView)
        view.addSubview(pinLabel)
        view.addSubview(keypadView)
        view.addSubview(nextButton)
        
        enableNextButton(false)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            pinLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            pinLabel.bottomAnchor.constraint(equalTo: keypadView.topAnchor, constant: -26),
            
            keypadView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            keypadView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            keypadView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            keypadView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.57),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -33),
            nextButton.heightAnchor.constraint(equalToConstant: 58),
        ])
    }

    // MARK: - Setup PIN Boxes
    
    private func setupPinFields() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 18
        stackView.distribution = .fillEqually

        for _ in 0..<pinLength {
            let label = UILabel()
            label.textAlignment = .center
            label.font = Fonts.boldOpenSans(ofSize: 26)
            label.textColor = Colors.titleNewColor
            label.backgroundColor = .clear
            label.layer.borderWidth = 1
            label.layer.borderColor = Colors.borderColorNew.cgColor
            label.layer.cornerRadius = Values.buttonRadius
            label.clipsToBounds = true
            label.heightAnchor.constraint(equalToConstant: 56).isActive = true
            pinLabels.append(label)
            stackView.addArrangedSubview(label)
        }

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: pinLabel.topAnchor, constant: -16),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 260)
        ])
    }

    // MARK: - Setup Keypad
    
    private func setupKeypad() {
        let keypadStack = UIStackView()
        keypadStack.axis = .vertical
        keypadStack.spacing = 18

        let numbers = [
            ["1","2","3"],
            ["4","5","6"],
            ["7","8","9"],
            ["","0","⌫"]
        ]

        for row in numbers {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 18
            rowStack.distribution = .fillEqually

            for value in row {
                let button = UIButton(type: .system)
                button.setTitle(value, for: .normal)
                button.titleLabel?.font = Fonts.regularOpenSans(ofSize: 26)
                button.backgroundColor = Colors.cellGroundColor2
                button.setTitleColor(Colors.titleColor3, for: .normal)
                button.layer.cornerRadius = Values.buttonRadius
                button.heightAnchor.constraint(equalToConstant: 60).isActive = true
                button.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)

                if value.isEmpty {
                    button.isEnabled = false
                    button.backgroundColor = .clear
                }

                rowStack.addArrangedSubview(button)
            }

            keypadStack.addArrangedSubview(rowStack)
        }

        keypadView.addSubview(keypadStack)
        keypadStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            keypadStack.topAnchor.constraint(equalTo: keypadView.topAnchor, constant: 40),
            keypadStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            keypadStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])
    }
    
    // MARK: - Configure pin flow
    
    private func configureFlow() {
        switch flowStep {
        case .createPin:
            flowStep = .createPin
            title = "Create Password"
            pinLabel.text = "Enter your PIN"
            
        case .enterNewPin:
            flowStep = .enterOldPin
            title = "Change Password"
            pinLabel.text = "Enter Old PIN"
            
        case .verifyPin:
            flowStep = .verifyPin
            title = "Verify PIN"
            pinLabel.text = "Enter your 4 digit PIN"
            
        case .enterOldPin, .confirmNewPin, .confirmCreatePin:
            break
        }
    }

    // MARK: - Actions
    
    // Keypad action
    @objc private func keyTapped(_ sender: UIButton) {
        guard let value = sender.title(for: .normal) else { return }

        if value == "⌫" {
            deleteDigit()
        } else {
            addDigit(value)
        }
    }
    
    // Next button action
    @objc private func nextButtonTapped() {
        handlePinCompletion()
    }
    
    // MARK: - Private methods
    
    // Add digit to PIN
    private func addDigit(_ digit: String) {
        guard currentPin.count < pinLength else { return }

        currentPin.append(digit)
        
        let index = currentPin.count - 1
        pinLabels[index].text = "*"
        pinLabels[index].layer.borderColor = Colors.bothGreenColor.cgColor

        if currentPin.count == pinLength {
            enableNextButton(true)
        }
    }

    // Delete last digit from PIN
    private func deleteDigit() {
        guard !currentPin.isEmpty else { return }

        let index = currentPin.count - 1
        pinLabels[index].text = ""
        pinLabels[index].layer.borderColor = Colors.borderColorNew.cgColor
        currentPin.removeLast()
        enableNextButton(false)
    }
    
    // Handle pin completion
    private func handlePinCompletion() {
        switch flowStep {
        case .verifyPin:
            validateExistingPin()
            
        case .enterOldPin:
            validateOldPin()
            
        case .enterNewPin:
            firstPinEntry = currentPin
            flowStep = .confirmNewPin
            pinLabel.text = "Re-enter your PIN"
            resetPinUI()
            
        case .confirmNewPin:
            validateNewPinConfirmation()
            
        case .createPin:
            firstPinEntry = currentPin
            flowStep = .confirmCreatePin
            pinLabel.text = "Re-enter your PIN"
            resetPinUI()
            
        case .confirmCreatePin:
            validateCreatePinConfirmation()
        }
    }
    
    // Reset pin UI
    private func resetPinUI() {
        currentPin = ""
        pinLabels.forEach {
            $0.text = ""
            $0.layer.borderColor = Colors.borderColorNew.cgColor
        }
        enableNextButton(false)
    }
    
    // Validate existing pin
    private func validateExistingPin() {
        if currentPin == SaveUserDefaultsData.BChatPassword {
            gotoSeedView()
        } else {
            showErrorMessage(Alert.Alert_BChat_Enter_Pin_Message2)
            resetPinUI()
        }
    }
    
    // Validate old pin
    private func validateOldPin() {
        if currentPin == SaveUserDefaultsData.BChatPassword {
            flowStep = .enterNewPin
            pinLabel.text = "Enter New PIN"
            resetPinUI()
        } else {
            showErrorMessage(Alert.Alert_BChat_Enter_Pin_Message2)
            resetPinUI()
        }
    }
    
    // Validate new pin confirmation
    private func validateNewPinConfirmation() {
        guard let firstPin = firstPinEntry else { return }

        if currentPin == SaveUserDefaultsData.BChatPassword {
            showErrorMessage("New password should not be same as old password.")
            flowStep = .enterNewPin
            pinLabel.text = "Enter New PIN"
            resetPinUI()
            return
        }

        if currentPin == firstPin {
            SaveUserDefaultsData.BChatPassword = currentPin
            showConfirmationModal("Your password has been changed successfully!")
        } else {
            showErrorMessage("PIN do not match.")
            flowStep = .enterNewPin
            pinLabel.text = "Enter New PIN"
            resetPinUI()
        }
    }
    
    // Validate create pin confirmation
    private func validateCreatePinConfirmation() {
        guard let firstPin = firstPinEntry else { return }

        if currentPin == firstPin {
            SaveUserDefaultsData.BChatPassword = currentPin
            showConfirmationModal("Your password has been set up successfully!")

            switch createPinDestination {
            case .restoreSeed:
                gotoRestoreSeedView()
            case .home:
                gotoHome()
            }
        } else {
            showErrorMessage("PIN do not match.")
            flowStep = .createPin
            pinLabel.text = "Enter your PIN"
            resetPinUI()
        }
    }
    
    // Enable/disable next button
    private func enableNextButton(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        nextButton.backgroundColor = isEnabled ? Colors.bothGreenColor : Colors.cellGroundColor2
        nextButton.setTitleColor(isEnabled ? Colors.bothWhiteColor : Colors.buttonDisableColor, for: .normal)
    }
    
    // Go to home view
    private func gotoHome() {
        UserDefaults.standard[.isUsingFullAPNs] = true
        TSAccountManager.sharedInstance().didRegister()
        let homeVC = HomeVC()
        navigationController?.setViewControllers([ homeVC ], animated: true)
        let syncTokensJob = SyncPushTokensJob(accountManager: AppEnvironment.shared.accountManager, preferences: Environment.shared.preferences)
        syncTokensJob.uploadOnlyIfStale = false
        let _: Promise<Void> = syncTokensJob.run()
    }
    
    // Go to recovery seed view
    private func gotoSeedView() {
        let vc = RecoverySeedViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Go to restore seed view
    private func gotoRestoreSeedView() {
        let vc = NewRestoreSeedVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Show error msg
    private func showErrorMessage(_ message: String) {
        _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: message) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: { })
    }
    
    // Show confirmation modal
    private func showConfirmationModal(_ title: String) {
        let confirmationModal: ConfirmationModal = ConfirmationModal(
            info: ConfirmationModal.Info(
                modalType: .pwdUpdateSuccess,
                title: title,
                body: .text(""),
                showCondition: .disabled,
                confirmEnabled: false,
                cancelTitle: "OK",
                cancelEnabled: true,
                onConfirm: { _ in
                }, dismissHandler: {
                    if self.flowStep == .confirmNewPin {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            )
        )
        present(confirmationModal, animated: true, completion: nil)
    }
}
