//
//  TransactionHistory.swift
//  beldex-ios-wallet
//
//  Created by Beldex International Limited OU on 16/11/22.
//

import Foundation

public struct TransactionItem {

    public var direction: TransactionDirection
    public var isPending: Bool
    public var isFailed: Bool
    public let amount: String
    public let networkFee: String
    public let timestamp: UInt64
    public let confirmations: UInt64
    public let paymentId: String
    public let hash: String
    public let label: String
    public let blockHeight: UInt64
    public let token: String
    
    public init(direction: TransactionDirection,
                isPending: Bool,
                isFailed: Bool,
                amount: UInt64,
                networkFee: UInt64,
                timestamp: UInt64,
                paymentId: String,
                hash: String,
                label: String,
                blockHeight: UInt64,
                confirmations: UInt64)
    {
        self.direction = direction
        self.isPending = isPending
        self.isFailed = isFailed
        self.amount = BChatWalletWrapper.displayAmount(amount)
        self.networkFee = BChatWalletWrapper.displayAmount(networkFee)
        self.timestamp = timestamp
        self.confirmations = confirmations
        self.paymentId = paymentId
        self.hash = hash
        self.label = label
        self.blockHeight = blockHeight
        self.token = "BDX"
    }
    
    public init(model: BeldexTrxHistory)
    {
        switch model.direction {
        case .in:
            self.direction = .received
        case .out:
            self.direction = .sent
        @unknown default:
            fatalError()
        }
        self.isPending = model.isPending
        self.isFailed = model.isFailed
        self.amount = BChatWalletWrapper.displayAmount(model.amount)
        self.networkFee = BChatWalletWrapper.displayAmount(model.fee)
        self.timestamp = UInt64(model.timestamp)
        self.confirmations = model.confirmations
        self.paymentId = model.paymentId
        self.hash = model.hashValue
        self.label = model.label
        self.blockHeight = model.blockHeight
        self.token = "BDX"
    }
}

public class TransactionHistory {
    
    public typealias ItemList = [TransactionItem]
    
    private var value: (all: ItemList, send: ItemList, receive: ItemList)
    
    public var all: ItemList {
        get { return value.all }
    }
    public var send: ItemList {
        get { return value.send }
    }
    public var receive: ItemList {
        get { return value.receive }
    }
    
    public init(_ items: ItemList) {
        self.value = (items, [], [])
        for item in items {
            switch item.direction {
            case .sent:
                self.value.send.append(item)
            case .received:
                self.value.receive.append(item)
            }
        }
    }
    
}
