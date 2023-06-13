// Copyright © 2022 Beldex All rights reserved.
import Foundation
import UIKit
import BChatUIKit

public var navigationflowTag = true

class LandingVC: BaseVC {
    
    @IBOutlet weak var createRef:UIButton!
    @IBOutlet weak var signRef:UIButton!
    @IBOutlet weak var TermsRef:UIButton!
    @IBOutlet weak var gifimg:UIImageView!
    @IBOutlet weak var btnterms:UIButton!
    var flagvalue:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGradientBackground()
        // Do any additional setup after loading the view.
        guard let navigationBar = navigationController?.navigationBar else { return }
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.navigationBarBackground2
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance;
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Colors.navigationBarBackground2
        }
        self.navigationItem.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        signRef.layer.cornerRadius = 6
        createRef.layer.cornerRadius = 6
        
        if isLightMode {
            gifAnimationLightMode()
            termsAndConditionsUtilitiesDark()
        }else {
            gifAnimationDarkMode()
            termsAndConditionsUtilitiesWhite()
        }
    }
    @objc override internal func handleAppModeChangedNotification(_ notification: Notification) {
        super.handleAppModeChangedNotification(notification)
        if isLightMode {
            gifAnimationLightMode()
            termsAndConditionsUtilitiesDark()
        }
        if isSystemDefault {
            if isLightMode {
                gifAnimationLightMode()
                termsAndConditionsUtilitiesDark()
            }else {
                gifAnimationDarkMode()
                termsAndConditionsUtilitiesWhite()
            }
        }
        else {
            gifAnimationDarkMode()
            termsAndConditionsUtilitiesWhite()
        }
    }
    
    // MARK: - Animation
    func gifAnimationLightMode(){
        do {
            let imageData = try Data(contentsOf: Bundle.main.url(forResource: "gifAnimation_white", withExtension: "gif")!)
            gifimg.image = UIImage.gif(data: imageData)
        } catch {
            print(error)
        }
    }
    func gifAnimationDarkMode(){
        do {
            let imageData = try Data(contentsOf: Bundle.main.url(forResource: "gifAnimation_dark", withExtension: "gif")!)
            gifimg.image = UIImage.gif(data: imageData)
        } catch {
            print(error)
        }
    }
    
    // MARK: - TermsAndConditions
    func termsAndConditionsUtilitiesWhite(){
        createRef.backgroundColor = UIColor.lightGray
        let image1 = UIImage(named: "unChecked_dark.png")!
        let tintedImage = image1.withRenderingMode(.alwaysTemplate)
        self.btnterms.setImage(tintedImage, for: .normal)
        btnterms.tintColor = .white
    }
    func termsAndConditionsUtilitiesDark(){
        createRef.backgroundColor = UIColor.lightGray
        let image1 = UIImage(named: "unChecked_dark.png")!
        let tintedImage = image1.withRenderingMode(.alwaysTemplate)
        self.btnterms.setImage(tintedImage, for: .normal)
        btnterms.tintColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        guard let navigationBar = navigationController?.navigationBar else { return }
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.navigationBarBackground2
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance;
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        } else {
            navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Colors.navigationBarBackground2
        }
        flagvalue = false
        if isLightMode {
            termsAndConditionsUtilitiesDark()
        }else {
            termsAndConditionsUtilitiesWhite()
        }
    }
    
    // MARK: - Create Account
    
    @IBAction func CraeteAction(sender:UIButton){
        if flagvalue == true {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DisplayNameVC") as! DisplayNameVC
            navigationflowTag = false
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            _ = CustomAlertController.alert(title: Alert.Alert_BChat_title, message: String(format: Alert.Alert_BChat_Terms_Condition_Message) , acceptMessage:NSLocalizedString(Alert.Alert_BChat_Ok, comment: "") , acceptBlock: {

            })
        }
    }
    // MARK: - Sign InAccount
    @IBAction func SignINAction(sender:UIButton){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecoverySeedVC") as! RecoverySeedVC
        navigationflowTag = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func TermsAction(sender:UIButton){
        let urlAsString: String?
        urlAsString = bchat_TermsConditionUrl_Link
        if let urlAsString = urlAsString {
            let url = URL(string: urlAsString)!
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func termsandconditionAction(sender:UIButton){
        btnterms.isSelected = !btnterms.isSelected
        if btnterms.isSelected {
            flagvalue = true
            createRef.backgroundColor = Colors.bchat_button_clr
            let img = UIImage(named: "checked_img.png")!
            let tintedImage = img.withRenderingMode(.alwaysTemplate)
            self.btnterms.setImage(tintedImage, for: .normal)
            btnterms.tintColor = isLightMode ? .black : .white
        }else {
            flagvalue = false
            if isLightMode {
                termsAndConditionsUtilitiesDark()
            }else {
                termsAndConditionsUtilitiesWhite()
            }
        }
    }
    
}
