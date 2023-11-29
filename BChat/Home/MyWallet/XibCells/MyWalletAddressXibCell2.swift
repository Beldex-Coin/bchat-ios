// Copyright © 2023 Beldex International Limited OU. All rights reserved.

import UIKit

class MyWalletAddressXibCell2: UICollectionViewCell {

    static let identifier = "MyWalletAddressXibCell2"
    static let nib = UINib(nibName: "MyWalletAddressXibCell2", bundle: nil)
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var subView:UIView!
    @IBOutlet weak var lblmyaddress:UILabel!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var btnshare:UIButton!
    @IBOutlet weak var img:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 6
        subView.layer.cornerRadius = 4
        lblmyaddress.layer.cornerRadius = 4
        lblmyaddress.clipsToBounds = true
        let logoName = isLightMode ? "ic_send_dark" : "ic_send"
        img.image = UIImage(named: logoName)!
        
    }
}
