//
//  ExpandableHeaderView.swift
//  DropDown tableViewCell
//
//  Created by Mehul  Singhal  on 04/07/17.
//  Copyright © 2017 Mehul  Singhal . All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate
{
    func toggleSection(header: UITableViewHeaderFooterView, section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (selectHeaderAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer)
    {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate)
    {
        self.textLabel?.text = title
        self.textLabel?.font = self.textLabel?.font.withSize(13)
        self.section = section
        self.delegate = delegate
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.textColor = Colors.bchat_lbl_name
        self.contentView.backgroundColor = Colors.bchat_view_bg_clr
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
