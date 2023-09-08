// Copyright © 2022 Beldex. All rights reserved.

import UIKit
import CoreMedia

class DisplayBChatIDsVC: BaseVC {
    
    
    @IBOutlet weak var backgroundBChatIDView:UIView!
    @IBOutlet weak var subbackgroundBChatIDView:UIView!
    @IBOutlet weak var lblbchatid:UILabel!
    @IBOutlet weak var lblBeldexAddress:UILabel!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var nextRef:UIButton!
    @IBOutlet weak var backgroundBeldexIDView:UIView!
    @IBOutlet weak var subbackgroundBeldexIDView:UIView!
    var userNameString:String!
    var bchatIDString:String!
    var beldexAddressIDString:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpGradientBackground()
        setUpNavBarStyle()
        
        self.title = "Register"
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        backgroundBChatIDView.layer.cornerRadius = 5
        subbackgroundBChatIDView.layer.cornerRadius = 5
        backgroundBeldexIDView.layer.cornerRadius = 5
        subbackgroundBeldexIDView.layer.cornerRadius = 5
        self.lblname.text = "Hey \(userNameString!), welcome to BChat!"
        nextRef.layer.cornerRadius = 6
        self.lblbchatid.text = bchatIDString!
        lblbchatid.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? Values.smallFontSize : Values.smallFontSize)
        lblbchatid.lineBreakMode = .byTruncatingTail
        self.lblBeldexAddress.text = beldexAddressIDString!
        lblBeldexAddress.font = Fonts.OpenSans(ofSize: isIPhone5OrSmaller ? Values.smallFontSize : Values.smallFontSize)
        lblBeldexAddress.lineBreakMode = .byTruncatingTail
        
    }
    
    @IBAction func nextAction(sender:UIButton){
        if navigationflowTag == false {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnterPinVC") as! EnterPinVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
