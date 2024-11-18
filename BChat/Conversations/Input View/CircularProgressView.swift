// Copyright © 2024 Beldex International Limited OU. All rights reserved.

import UIKit

class CircularProgressView: UIView {
    private var progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(arcCenter: center, radius: bounds.width / 2, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // Background layer
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = Colors.bchatPlaceholderColor.cgColor
        backgroundLayer.lineWidth = 2.2
        backgroundLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = Colors.accent.cgColor
        progressLayer.lineWidth = 2.2
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }

    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
}
