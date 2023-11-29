// Copyright © 2022 Beldex International Limited OU. All rights reserved.

import UIKit

protocol ExpandedCellDelegate:NSObjectProtocol{
    func topButtonTouched(indexPath:IndexPath)
}

class WalletHomeXibCell: UICollectionViewCell {
    
    static let identifier = "WalletHomeXibCell"
    static let nib = UINib(nibName: "WalletHomeXibCell", bundle: nil)
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var imgpic:UIImageView!
    @IBOutlet weak var lbldate:UILabel!
    @IBOutlet weak var lblamount:UILabel!
    @IBOutlet weak var lbltraID:UILabel!
    @IBOutlet weak var lblSendandReceive:UILabel!
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var lbldateandtime:UILabel!
    @IBOutlet weak var lblheight:UILabel!
    @IBOutlet weak var lblfee:UILabel!
    @IBOutlet weak var lblReceipentAddress:UILabel!
    @IBOutlet weak var lblfeeTitle:UILabel!
    @IBOutlet weak var lblReceipentAddressTitle:UILabel!
    @IBOutlet weak var topButton: UIButton!
    weak var delegate:ExpandedCellDelegate?
    public var indexPath:IndexPath!
    
    @IBAction func topButtonTouched(_ sender: UIButton) {
        if let delegate = self.delegate{
            delegate.topButtonTouched(indexPath: indexPath)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 6
    }
    
}
