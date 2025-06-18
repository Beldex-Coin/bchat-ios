// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation

extension UITextView{
    func setPlaceholderChatNew() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("ENTER_CHAT_ID_NEW", comment: "")
        placeholderLabel.font = Fonts.OpenSans(ofSize: 14)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        placeholderLabel.textColor = UIColor(hex: 0xA7A7BA)
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
    func checkPlaceholderChatNew() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}

extension UITextView{
    func setPlaceholder() {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Enter BChat ID"
        placeholderLabel.font = Fonts.OpenSans(ofSize: Values.smallFontSize)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (self.font?.pointSize)! / 0.7)
        placeholderLabel.textColor = Colors.text.withAlphaComponent(Values.mediumOpacity)
        placeholderLabel.isHidden = !self.text.isEmpty
        self.addSubview(placeholderLabel)
    }
    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}
