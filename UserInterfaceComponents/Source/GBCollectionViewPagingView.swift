//
//  GBCollectionViewPagingView.swift
//  UserInterfaceComponents
//
//  Created by Guillaume Bourachot on 20/12/2018.
//  Copyright © 2018 Guillaume Bourachot. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class GBCollectionViewPagingView: UIView {
    
    //MARK: - Variables
    @IBInspectable var filledColor:UIColor = UIColor.red {
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var emptyColor:UIColor = UIColor.blue{
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var contentHeight:CGFloat = 20.0{
        didSet{
            self.setNeedsLayout()
        }
    }
    @IBInspectable var indicatorSpacing: CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    @IBInspectable var numberOfPage: Int = 5 {
        didSet{
            self.populatePageIndicatorLayers(pageCount: numberOfPage)
            self.setNeedsLayout()
        }
    }
    @IBInspectable var selectedPage: Int = 1 {
        didSet{
            self.select(pageNumber: selectedPage)
            self.setNeedsLayout()
        }
    }
    private var pageIndicatorLayers : [CAShapeLayer] = []
    var intrinsicContentWidth: CGFloat = 0.0
    
    //MARK: - Life cycle
    init(pageCount: Int, frame:CGRect){
        super.init(frame: frame)
        self.numberOfPage = pageCount
        self.populatePageIndicatorLayers(pageCount: numberOfPage)
    }
    
    override convenience init(frame: CGRect) {
        self.init(pageCount: 5, frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Functions
    private func populatePageIndicatorLayers(pageCount: Int) {
        self.pageIndicatorLayers.forEach {$0.removeFromSuperlayer()}
        self.pageIndicatorLayers.removeAll()
        self.pageIndicatorLayers = (0..<pageCount).map {_ in CAShapeLayer()}
        self.pageIndicatorLayers.forEach {self.layer.addSublayer($0)}
    }
    
    private func circleShape() -> UIBezierPath {
        let arcCenter   = CGPoint(x: contentHeight/2, y: contentHeight/2)
        let radius      = Float(min((contentHeight/2) - 1, (contentHeight/2)-1))
        let startAngle = CGFloat(Int(-90)) * .pi / 180
        let endAngle = CGFloat(Int(360-90)) * .pi / 180
        return UIBezierPath(arcCenter: arcCenter, radius:
            CGFloat(radius), startAngle: startAngle, endAngle: endAngle, clockwise: true)
    }
    
    private func select(pageNumber: Int){
        for (index,layer) in pageIndicatorLayers.enumerated() {
            if index == pageNumber {
                layer.fillColor = self.filledColor.cgColor
            } else {
                layer.fillColor = self.emptyColor.cgColor
            }
        }
    }
    
    //MARK: - Layout    
    override func layoutSubviews() {
        super.layoutSubviews()
        let spaceBetweenPageIndicators = self.indicatorSpacing + (self.indicatorSpacing/CGFloat(self.numberOfPage))
        
        for (index,layer) in pageIndicatorLayers.enumerated() {
            layer.frame = CGRect(x: (contentHeight+spaceBetweenPageIndicators)*CGFloat(index),y: 0,width: contentHeight,height: contentHeight)
            layer.path = self.circleShape().cgPath
        }
    }
    override var intrinsicContentSize: CGSize {
        let spaceBetweenPageIndicators = self.indicatorSpacing + (self.indicatorSpacing/CGFloat(self.numberOfPage))
        self.intrinsicContentWidth = CGFloat(self.numberOfPage)*(contentHeight+spaceBetweenPageIndicators)-spaceBetweenPageIndicators
        return CGSize(width: self.intrinsicContentWidth, height: self.contentHeight)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedPage = 0
    }
}
