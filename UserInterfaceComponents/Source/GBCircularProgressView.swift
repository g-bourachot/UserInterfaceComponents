//
//  GBCircularProgressView.swift
//  GBCircularProgressView
//
//  Created by Guillaume Bourachot on 22/03/2018.
//  Copyright © 2018 Guillaume Bourachot. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GBCircularProgressView : UIView {
    
    //MARK: - Variables
    @IBInspectable var progressColor:UIColor = UIColor.green {
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var trackColor:UIColor = UIColor.gray {
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var trackWidth:CGFloat = 1.0{
        didSet{
            self.setNeedsLayout()
        }
    }
    var progress: Float = 0.5 {
        didSet(newValue) {
            self.refreshUI()
        }
    }
    private var progressLayer : CAShapeLayer!
    private var backgroundLayer : CAShapeLayer!
    
    //MARK: - SetUp Functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    //MARK: - Functions
    private func setUp() {
        let arcCenter   = CGPoint(x: (self.bounds.midX), y: (self.bounds.midY))
        let radius      = Float(min((self.bounds.midX) - 1, (self.bounds.midY)-1))
        let startAngle = CGFloat(Int(-90)) * .pi / 180
        let endAngle = CGFloat(Int(360-90)) * .pi / 180
        let circlePath : UIBezierPath = UIBezierPath(arcCenter: arcCenter, radius:
            CGFloat(radius), startAngle: startAngle, endAngle: endAngle, clockwise: true)

        self.backgroundColor = UIColor.clear
        self.backgroundLayer = CAShapeLayer()
        self.backgroundLayer.path = circlePath.cgPath
        self.backgroundLayer.strokeColor = self.trackColor.cgColor
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.backgroundLayer.lineWidth = self.trackWidth
        
        self.progressLayer = CAShapeLayer()
        self.progressLayer.frame = self.bounds
        self.progressLayer.path = circlePath.cgPath
        self.progressLayer.lineWidth = self.trackWidth
        self.progressLayer.strokeColor = self.progressColor.cgColor
        self.progressLayer.fillColor = nil
        self.progressLayer.strokeStart = 0.0
        self.progressLayer.strokeEnd = 0.0
        
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(progressLayer)
    }
    
    private func refreshUI() {
        self.backgroundLayer.strokeColor = self.trackColor.cgColor
        self.backgroundLayer.lineWidth = self.trackWidth
        self.progressLayer.strokeColor = self.progressColor.cgColor
        self.progressLayer.lineWidth = self.trackWidth
        self.progressLayer.strokeEnd = CGFloat(self.progress)
    }
    
    //MARK: - Layout
    override func layoutSubviews() {
        self.setUp()
        self.refreshUI()
    }
}
