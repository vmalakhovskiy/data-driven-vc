//
//  Ring.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/19/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import UIKit

public class Ring: UIView {
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let halfSize = min(bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth: CGFloat = 1
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: halfSize - (desiredLineWidth / 2),
            startAngle: 0,
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true
        )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }
}
