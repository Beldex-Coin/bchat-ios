//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString.Key {
    static let attachmentBlockQuote = NSAttributedString.Key("attachmentBlockQuote")
}

class AttachmentTextView: UITextView {
    // When creating new lines, contentOffset is animated, but because
    // we are simultaneously resizing the text view, this can cause the
    // text in the textview to be "too high" in the text view.
    // Solution is to disable animation for setting content offset.
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        super.setContentOffset(contentOffset, animated: false)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBlockQuoteBars()
    }
    
    private func drawBlockQuoteBars() {
        guard let attributed = attributedText, attributed.length > 0 else { return }
        let fullRange = NSRange(location: 0, length: attributed.length)
        let nsText = attributed.string as NSString
        
        attributed.enumerateAttribute(.attachmentBlockQuote, in: fullRange, options: []) { value, range, _ in
            guard let isQuote = value as? Bool, isQuote, range.length > 0 else { return }
            if range.location + 3 <= nsText.length {
                let prefix = nsText.substring(with: NSRange(location: range.location, length: 3))
                if prefix == ">  " { return }
            }
            
            let glyphRange = self.layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            self.layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, _, _ in
                let barX = self.textContainerInset.left + self.textContainer.lineFragmentPadding - self.contentOffset.x + 2
                let barY = usedRect.minY + self.textContainerInset.top - self.contentOffset.y + 1
                let barHeight = max(usedRect.height + 1, 5)
                let barRect = CGRect(x: barX, y: barY, width: 3, height: barHeight)
                let path = UIBezierPath(roundedRect: barRect, cornerRadius: 1.5)
                UIColor.systemGray2.setFill()
                path.fill()
            }
        }
    }
}
