// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import UIKit

protocol ExpandedCellDelegate:NSObjectProtocol{
    func topButtonTouched(indexPath:IndexPath)
}

class WalletHomeXibCell: UICollectionViewCell {
    
    static let identifier = "WalletHomeXibCell"
    static let nib = UINib(nibName: "WalletHomeXibCell", bundle: nil)
    
    @IBOutlet weak var view1:UIView!
    @IBOutlet weak var imgpic:UIImageView!
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var sublblname:UILabel!
    
    
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
        
        view1.layer.cornerRadius = 6
        
    }

}
