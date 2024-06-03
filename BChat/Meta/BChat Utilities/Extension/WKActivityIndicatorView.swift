//
//  WKActivityIndicatorView.swift
//  Beldex
//
//  Created by BeldexWallet on 2020/5/15.
//  Copyright © 2020 Beldex. All rights reserved.
//

import UIKit

class WKActivityIndicatorView: UIActivityIndicatorView {

    // MARK: - Properties (public)

    public var isLoading = false {
        didSet {
            guard isLoading != oldValue else {
                return
            }
            isLoading ? startAnimating() : stopAnimating()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if isLoading && !isAnimating {
            startAnimating()
        }
    }
}
