//
//  Decimal + Ext.swift


import Foundation

extension Decimal {
    
    func scaleString(_ scale: Int16) -> String {
        let number = NSDecimalNumber.init(decimal: self)
        let handler = NSDecimalNumberHandler.init(roundingMode: .plain, scale: scale, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let scaleStr = number.rounding(accordingToBehavior: handler).stringValue
        if scaleStr.contains(".") {
            let components = scaleStr.components(separatedBy: ".")
            let intStr = components[0]
            let floatStr = components[1]
            return intStr + "." + floatStr + "0".repeatString(Int(scale) - floatStr.count)
        } else {
            return scaleStr + "." + "0".repeatString(Int(scale))
        }
    }
}

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}


extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}
