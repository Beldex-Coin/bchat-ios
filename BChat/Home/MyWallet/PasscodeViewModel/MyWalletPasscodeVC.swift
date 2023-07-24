// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit
import CoreMotion

enum PasscodeViewMode {
    case inactive
    case lockedScreen
    case passcodeEntry
}

class MyWalletPasscodeVC: BaseVC {
    var passcodeViewMode: PasscodeViewMode = .inactive
    
    @IBOutlet var passcodeDotsView: PasscodeDotsView!
    @IBOutlet var passcodeKeypadView: KeypadView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var lblEnterPin: UILabel!
    @IBOutlet var imgpic: UIImageView!
    var once = false
    var checkText = ""
    var twice = false
    var checkTextNew = ""
    var isChangePin = false
    var isEnterPin = false
    var isSendWalletVC = false
    var wallet: BDXWallet?
    var finalWalletAddress = ""
    var finalWalletAmount = ""
    
    var passcodeText : String = "" {
        didSet {
            if oldValue.count < passcodeText.count {
                passcodeDotsView.toggleDot(index: passcodeText.count - 1, filled: true)
            } else {
                passcodeDotsView.toggleDot(index: oldValue.count - 1, filled: false)
            }
            if passcodeText.count == 4 {
                if self.isEnterPin {
                    self.enterPin()
                    return
                }
                if self.isChangePin {
                    self.changePin()
                    return
                }
                if self.isSendWalletVC {
                    self.sendWalletVC()
                    return
                }
                changedText()
            }
        }
    }
    
    func changedText(){
        if once == true{
            if passcodeText != checkText{
                let alert = UIAlertController(title: "Incorrect Pin", message: "Passcode not matched, Enter again", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    self.checkText = ""
                    self.passcodeText.removeAll()
                    self.passcodeDotsView.toggleDot(index: 0, filled: false)
                    self.passcodeDotsView.toggleDot(index: 1, filled: false)
                    self.passcodeDotsView.toggleDot(index: 2, filled: false)
                    self.passcodeDotsView.toggleDot(index: 3, filled: false)
                    self.once = false
                    self.lblEnterPin.text = "Create Pin"
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }else{
                SaveUserDefaultsData.WalletPassword = passcodeText
                let alert = UIAlertController(title: "", message: "Your PIN has been set up successfully!", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletHomeVC") as! MyWalletHomeVC
                    self.navigationController?.pushViewController(vc, animated: true)
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            checkText = passcodeText
            passcodeText.removeAll()
            passcodeDotsView.toggleDot(index: 0, filled: false)
            passcodeDotsView.toggleDot(index: 1, filled: false)
            passcodeDotsView.toggleDot(index: 2, filled: false)
            passcodeDotsView.toggleDot(index: 3, filled: false)
            once = true
            lblEnterPin.text = "Re-Enter Pin"
        }
    }
    
    func enterPin() {
        if passcodeText != SaveUserDefaultsData.WalletPassword{
            let alert = UIAlertController(title: "Incorrect Pin", message: "Passcode not matched, Enter again", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.checkText = ""
                self.passcodeText.removeAll()
                self.passcodeDotsView.toggleDot(index: 0, filled: false)
                self.passcodeDotsView.toggleDot(index: 1, filled: false)
                self.passcodeDotsView.toggleDot(index: 2, filled: false)
                self.passcodeDotsView.toggleDot(index: 3, filled: false)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletHomeVC") as! MyWalletHomeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func changePin(){
        if once == true{
            if passcodeText == checkText{
                let alert = UIAlertController(title: "", message: "New pin and old pin can't be same, please enter a diferent pin", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    self.checkText = ""
                    self.passcodeText.removeAll()
                    self.passcodeDotsView.toggleDot(index: 0, filled: false)
                    self.passcodeDotsView.toggleDot(index: 1, filled: false)
                    self.passcodeDotsView.toggleDot(index: 2, filled: false)
                    self.passcodeDotsView.toggleDot(index: 3, filled: false)
                    self.once = false
                    self.lblEnterPin.text = "Enter your current 4-digit Pin"
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }else{
                if twice == true{
                    if passcodeText != checkTextNew{
                        let alert = UIAlertController(title: "Incorrect New pin", message: "Passcode not matched, Enter New Pin again", preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                            self.checkTextNew = ""
                            self.passcodeText.removeAll()
                            self.passcodeDotsView.toggleDot(index: 0, filled: false)
                            self.passcodeDotsView.toggleDot(index: 1, filled: false)
                            self.passcodeDotsView.toggleDot(index: 2, filled: false)
                            self.passcodeDotsView.toggleDot(index: 3, filled: false)
                            self.twice = false
                            self.lblEnterPin.text = "Create Pin"
                        })
                        alert.addAction(okayAction)
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        SaveUserDefaultsData.WalletPassword = passcodeText
                        let alert = UIAlertController(title: "", message: "Your PIN has been changed successfully!", preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyWalletHomeVC") as! MyWalletHomeVC
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        alert.addAction(okayAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    checkTextNew = passcodeText
                    passcodeText.removeAll()
                    passcodeDotsView.toggleDot(index: 0, filled: false)
                    passcodeDotsView.toggleDot(index: 1, filled: false)
                    passcodeDotsView.toggleDot(index: 2, filled: false)
                    passcodeDotsView.toggleDot(index: 3, filled: false)
                    twice = true
                    lblEnterPin.text = "Re-Enter Pin"
                }
            }
        }else{
            if passcodeText == SaveUserDefaultsData.WalletPassword{
                checkText = passcodeText
                passcodeText.removeAll()
                passcodeDotsView.toggleDot(index: 0, filled: false)
                passcodeDotsView.toggleDot(index: 1, filled: false)
                passcodeDotsView.toggleDot(index: 2, filled: false)
                passcodeDotsView.toggleDot(index: 3, filled: false)
                once = true
                lblEnterPin.text = "Create Pin"
            }else{
                let alert = UIAlertController(title: "", message: "Please enter correct current pin", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    self.checkText = ""
                    self.passcodeText.removeAll()
                    self.passcodeDotsView.toggleDot(index: 0, filled: false)
                    self.passcodeDotsView.toggleDot(index: 1, filled: false)
                    self.passcodeDotsView.toggleDot(index: 2, filled: false)
                    self.passcodeDotsView.toggleDot(index: 3, filled: false)
                    self.once = false
                    self.lblEnterPin.text = "Enter your current 4-digit Pin"
                })
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func sendWalletVC() {
        if passcodeText != SaveUserDefaultsData.WalletPassword{
            let alert = UIAlertController(title: "Incorrect Pin", message: "Passcode not matched, Enter again", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.checkText = ""
                self.passcodeText.removeAll()
                self.passcodeDotsView.toggleDot(index: 0, filled: false)
                self.passcodeDotsView.toggleDot(index: 1, filled: false)
                self.passcodeDotsView.toggleDot(index: 2, filled: false)
                self.passcodeDotsView.toggleDot(index: 3, filled: false)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }else{
            if self.navigationController != nil{
                let count = self.navigationController!.viewControllers.count
                if count > 1
                {
                    let VC = self.navigationController!.viewControllers[count-2] as! MyWalletSendVC
                    VC.wallet = self.wallet
                    VC.finalWalletAddress = self.finalWalletAddress
                    VC.finalWalletAmount = self.finalWalletAmount
                    VC.BackAPI = true
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var motionManager: CMMotionManager = CMMotionManager()
    func lockedScreenViewsGroup() -> [UIView] {
        return []
    }
    func passcodeEntryViewsGroup() -> [UIView] {
        return [passcodeDotsView, passcodeKeypadView, cancelButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Wallet Password"
        
        if self.isEnterPin {
            lblEnterPin.text = "Enter Pin"
        }
        if self.isChangePin {
            lblEnterPin.text = "Enter your current 4-digit Pin"
        }
        if self.isSendWalletVC {
            lblEnterPin.text = "Enter Pin"
        }
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if isLightMode {
            imgpic.image = UIImage(named: "ic_WalletPasswordlogo")
        } else {
            imgpic.image = UIImage(named: "ic_WalletPasswordlogoWhite")
        }
        setPasscodeViewMode(.passcodeEntry)
        passcodeKeypadView.delegate = self
        
    }
    
    
    
    // MARK: - Navigation
    
    /// This method will start a timer to either "wake" the device or put it to sleep if it is in the right orientation.
    /// On a timer because the real device seems to delay it by a bit.
    func handleDeviceMotion(motion: CMDeviceMotion) {
        // device is tilted up
        if motion.attitude.pitch > 0.5 {
        } else { //device is tilted down
            if passcodeViewMode == .lockedScreen {
                //delay switching to inactive mode for a sec
            }
        }
    }
    
    /// Make sure views are in the right state
    func initialViewSetup() {
        for view in self.passcodeEntryViewsGroup() {
            view.alpha = 0.0
        }
        
        for view in self.lockedScreenViewsGroup() {
            view.alpha = 1.0
        }
        ///  inactiveView.alpha = 1.0
    }
    
    /// Handles state transitions between inactive (black screen), locked screen (clock, date, flashlight, other stuff) and the passcode entry modes
    func setPasscodeViewMode(_ mode: PasscodeViewMode) {
        // if we change state then just invalidate the tilt timer
        guard passcodeViewMode != mode else { return }
        let previousMode = passcodeViewMode
        passcodeViewMode = mode
        
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        
        switch mode {
            // If we're switching to inactive, make the black screen appear
        case .inactive:
            UIView.animate(withDuration: 0.2, animations: {
                // self.inactiveView.alpha = 1.0
            })
        case .lockedScreen:
            // if we came from the passcode entry view, animate it out, otherwise we're coming from the dark view so animate that one out
            if previousMode == .passcodeEntry {
                UIView.animate(withDuration: 0.2, animations: {
                    for view in self.passcodeEntryViewsGroup() {
                        view.alpha = 0.0
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    //  self.inactiveView.alpha = 0.0
                })
            }
            
            // If we're coming from the inactive mode, set a timer to show the passcode mode
            if previousMode == .inactive {
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
                    self.setPasscodeViewMode(.passcodeEntry)
                })
            }
            
            // Play the haptic feedback sound and animate the passcode entry views in
        case .passcodeEntry:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)
            UIView.animate(withDuration: 0.2, animations: {
                for view in self.passcodeEntryViewsGroup() {
                    view.alpha = 1.0
                }
            })
        }
    }
    
    /// Lets the user get to the passcode entry state by tapping the locked screen
    @IBAction func lockedScreenBackgroundTapped(_ sender: Any) {
        setPasscodeViewMode(.passcodeEntry)
    }
    
    /// Lets the user get out of the asleep state by tapping
    @IBAction func inactiveScreenTapped(_ sender: Any) {
        setPasscodeViewMode(.lockedScreen)
    }
    
    // MARK: status bar and home indicator stuff
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // hide the status bar on the "sleep" screen
    override var prefersStatusBarHidden: Bool {
        switch passcodeViewMode {
        case .inactive:
            return true
        default:
            return false
        }
    }
    
    // Hides the home indicator on the inactive and passcode entry view
    func prefersHomeIndicatorAutoHidden() -> Bool {
        switch passcodeViewMode {
        case .inactive, .passcodeEntry:
            return true
        default:
            return false
        }
    }
    
    /// Prevents the user from swiping up to dismiss the app.
    func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return UIRectEdge.bottom
    }
    
    // handle the swipe up from the bottom of the screen
    @objc func handlePan(_ sender: Any) {
        if passcodeViewMode == .lockedScreen {
            setPasscodeViewMode(.passcodeEntry)
        }
    }
    
    // Deletes the last pressed entry or goes back to the lock screen
    @IBAction func cancelButtonPressed(_ sender: Any) {
        if passcodeText.count == 0 {
            // setPasscodeViewMode(.passcodeEntry)
            self.navigationController?.popViewController(animated: true)
        } else {
            passcodeText.remove(at: passcodeText.index(before: passcodeText.endIndex))
        }
    }
    
}
// Handles the keyboard view's delegate methods
extension MyWalletPasscodeVC : KeypadViewDelegate {
    func keypadButtonPressed(_ value: String) {
        guard passcodeText.count < 4 else { return }
        passcodeText.append(contentsOf: value)
    }
}
