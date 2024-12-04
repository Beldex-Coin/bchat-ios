// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import Foundation


class LeftTriangleView: UIView {

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Define the points for the right triangle
        let topRight = CGPoint(x: rect.width, y: 0)
        let bottomLeft = CGPoint(x: 0, y: rect.height)
        let bottomRight = CGPoint(x: rect.width, y: rect.height)
        
        // Set the fill color to a visible color (e.g., blue)
        context.setFillColor(Colors.mainBackGroundColor2.cgColor)
        
        // Set the stroke color to a visible color (e.g., black) for the border
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2) // Border width
        
        // Begin the path for the triangle
        context.move(to: topRight)
        context.addLine(to: bottomLeft)
        context.addLine(to: bottomRight)
        context.closePath()
        
        // Fill the triangle with the chosen color
        context.fillPath()
        
        // Draw the border around the triangle
        context.strokePath()
    }
}

class RightTriangleView: UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let topRight = CGPoint(x: 0, y: 0)
        let bottomRight = CGPoint(x: rect.width, y: rect.height)
        let bottomLeft = CGPoint(x: 0, y: rect.height)
        
        
        // Set the fill color to a visible color (e.g., blue)
        context.setFillColor(Colors.mainBackGroundColor2.cgColor)
        
        // Set the stroke color to a visible color (e.g., black) for the border
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2) // Border width
        
        
        context.move(to: topRight)
        context.addLine(to: bottomRight)
        context.addLine(to: bottomLeft)
        context.closePath()
        
        context.fillPath()
        
        // Draw the border around the triangle
        context.strokePath()
    }
}
