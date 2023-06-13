// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import BChatUtilitiesKit

public extension VisibleMessage {

    @objc(SNPayment)
    class Payment : NSObject, NSCoding {
        public var txnId: String?
        public var amount: String?

        @objc
        public init(txnId: String, amount: String) {
            self.txnId = txnId
            self.amount = amount
        }

        public required init?(coder: NSCoder) {
            if let txnId = coder.decodeObject(forKey: "txnId") as! String? { self.txnId = txnId }
            if let amount = coder.decodeObject(forKey: "amount") as! String? { self.amount = amount }
        }

        public func encode(with coder: NSCoder) {
            coder.encode(txnId, forKey: "txnId")
            coder.encode(amount, forKey: "amount")
        }

        public static func fromProto(_ proto: SNProtoDataMessagePayment) -> Payment? {
            let amount = proto.amount
            let txnId = proto.txnId
            return Payment(txnId: txnId, amount: amount)
        }

        public func toProto() -> SNProtoDataMessagePayment? {
            guard let amount = amount, let txnId = txnId else {
                SNLog("Couldn't construct payment proto from: \(self).")
                return nil
            }
            let paymentProto = SNProtoDataMessagePayment.builder(amount: amount, txnId: txnId)
            do {
                return try paymentProto.build()
            } catch {
                SNLog("Couldn't construct payment proto from: \(self).")
                return nil
            }
        }
        
        // MARK: Description
        public override var description: String {
            """
            Payment(
                        txnId: \(txnId ?? "null"),
                            amount: \(amount ?? "null")
            )
            """
        }
    }
}
