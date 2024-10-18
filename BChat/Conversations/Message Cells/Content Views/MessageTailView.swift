// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation


class LeftTriangleView: UIView {

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Define the points for the right triangle
        let topRight = CGPoint(x: rect.width, y: 0)
        let bottomLeft = CGPoint(x: 0, y: rect.height)
        let bottomRight = CGPoint(x: rect.width, y: rect.height)
        backgroundColor = .clear
        // Begin the path
        context.move(to: topRight)
        context.addLine(to: bottomLeft)
        context.addLine(to: bottomRight)
        context.closePath()

        context.fillPath()
    }
}

class RightTriangleView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let topRight = CGPoint(x: 0, y: 0)
        let bottomRight = CGPoint(x: rect.width, y: rect.height)
        let bottomLeft = CGPoint(x: 0, y: rect.height)
        backgroundColor = .clear
        context.move(to: topRight)
        context.addLine(to: bottomRight)
        context.addLine(to: bottomLeft)
        context.closePath()
        
        context.fillPath()
    }
}
