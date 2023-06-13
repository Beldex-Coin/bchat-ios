//
//  SettingsCell.swift
//  KMCA
//
//  Created by Blockhash on 23/02/22.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    @IBOutlet weak var lblname:UILabel!
    @IBOutlet weak var lblname1:UILabel!
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var swRef:UISwitch!
    @IBOutlet weak var arrowimg:UIImageView!
    @IBOutlet weak var Sublblname:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
