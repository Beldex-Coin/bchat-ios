//
//  Helper.swift


import UIKit

class Helper: NSObject {

    class func clipSuffix(_ text: String, clipChar: String) -> String {
        if text.hasSuffix(clipChar) {
            return clipSuffix(String(text.prefix(text.count - 1)), clipChar: clipChar)
        } else {
            return text
        }
    }
    
    class func displayDigitsAmount(_ original: String) -> String {
        guard original.contains(".") else {
            return original + ".00"
        }
        let components = original.components(separatedBy: ".")
        if components.count == 2 {
            let preffix = components[0]
            let suffix = components[1]
            let cliped = clipSuffix(suffix, clipChar: "0")
            if cliped == "" {
                return preffix + ".00"
            } else if cliped.count == 1 {
                return "\(preffix).\(cliped)0"
            }
            return preffix + "." + cliped
        }
        return original
    }
}
