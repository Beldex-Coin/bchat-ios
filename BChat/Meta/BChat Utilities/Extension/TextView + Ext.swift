// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension UITextView{
    func setPlaceholderChatNew() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("ENTER_CHAT_ID_NEW", comment: "")
        placeholderLabel.font = Fonts.OpenSans(ofSize: 14)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 2, y: 8)
        placeholderLabel.textColor = UIColor(hex: 0xA7A7BA)
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
    func checkPlaceholderChatNew() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
