//
//  Rounded2StatesButton.swift
//  UserInterfaceComponents
//
//  Created by Guillaume Bourachot on 20/12/2018.
//  Copyright © 2018 Guillaume Bourachot. All rights reserved.
//

import Foundation
import UIKit

protocol Rounded2StateButtonDelegate : class {
    func didTouchControl(sender: Rounded2StateButton)
}

@IBDesignable public class Rounded2StateButton : UIControl {
    
    public enum CheckState {
        case checked
        case unchecked
    }
    
    public enum ImagePosition : Int {
        case leading
        case trailing
    }
    
    //MARK: - Variables
    public let imageViewLeading : UIImageView = UIImageView(frame: CGRect.zero)
    public let imageViewTrailing : UIImageView = UIImageView(frame: CGRect.zero)
    public let contentStackView = UIStackView()
    public let titleLabel : UILabel = UILabel(frame: CGRect.zero)
    public let borderWidth : CGFloat = 2.0
    public let color : UIColor = UIColor.black
    weak var delegate : Rounded2StateButtonDelegate?
    
    public var title : String? {
        didSet {
            if self.titleLabel.text != self.title {
                self.titleLabel.text = self.title
                self.updateFrameSize()
                self.invalidateIntrinsicContentSize()
            }
        }
    }
    
    private let offset : (x:CGFloat, y:CGFloat) = (10.0, 5.0)
    
    public var checkState : CheckState = .unchecked {
        didSet {
            switch self.checkState {
            case .checked:
                self.image = self.selectedImage
            case .unchecked:
                self.image = self.unselectedImage
            }
            self.refreshUI()
        }
    }
    //MARK: - Inspectable variables
    @IBInspectable public var titleLocalizationKey : String? {
        didSet {
            if let key = self.titleLocalizationKey {
                #if TARGET_INTERFACE_BUILDER
                let bundle = Bundle(for: type(of: self))
                self.title = bundle.localizedString(forKey: key, value: "", table: nil)
                #else
                self.title = NSLocalizedString(key, comment:"");
                #endif
            }
        }
    }
    @IBInspectable public var selectedColor = UIColor.red {
        didSet {
            self.refreshUI()
        }
    }
    @IBInspectable public var unSelectedColor = UIColor.white {
        didSet {
            self.refreshUI()
        }
    }
    
    @IBInspectable public var imagePositionRaw : Int {
        get {
            return self.imagePosition.rawValue
        }
        set(value) {
            self.imagePosition = ImagePosition(rawValue: value)!
        }
    }
    public var imagePosition = Rounded2StateButton.ImagePosition.leading {
        didSet {
            switch self.imagePosition {
            case .leading:
                imageViewLeading.isHidden = false
                imageViewTrailing.isHidden = true
            case .trailing:
                imageViewLeading.isHidden = true
                imageViewTrailing.isHidden = false
            }
        }
    }
    
    @IBInspectable public var cornerRadius : Int = 0
    
    @IBInspectable public var changeRadius : Bool = false
    
    public var image : UIImage? {
        didSet {
            self.imageViewLeading.image = image
            self.imageViewTrailing.image = image
            self.invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var selectedImage : UIImage?
    @IBInspectable public var unselectedImage : UIImage?
    
    public var font = UIFont.systemFont(ofSize: 18, weight: .light) {
        didSet {
            self.titleLabel.font = self.font
        }
    }
    
    //MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.afterInitSetup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.afterInitSetup()
    }
    
    //MARK: - Functions
    private func afterInitSetup() {
        self.addTarget(self, action: #selector(toggleCheckState), for: .touchUpInside)
        
        //configuration
        self.contentMode = .redraw
        self.contentStackView.isUserInteractionEnabled = false
        
        //Image View Leading
        self.imageViewLeading.centerYAnchor.constraint(equalTo: self.contentStackView.centerYAnchor)
        self.imageViewLeading.centerXAnchor.constraint(equalTo: self.contentStackView.centerXAnchor)
        self.imageViewLeading.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewLeading.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
        
        //Text Label
        self.titleLabel.centerYAnchor.constraint(equalTo: self.contentStackView.centerYAnchor)
        self.titleLabel.centerXAnchor.constraint(equalTo: self.contentStackView.centerXAnchor)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.minimumScaleFactor = 0.7
        self.titleLabel.adjustsFontSizeToFitWidth = true
        
        //Stack view
        self.contentStackView.axis = .horizontal
        self.contentStackView.alignment = .center
        self.contentStackView.distribution = .equalSpacing
        self.contentStackView.spacing = 4
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        //Image View Trailing
        self.imageViewTrailing.centerYAnchor.constraint(equalTo: self.contentStackView.centerYAnchor)
        self.imageViewTrailing.centerXAnchor.constraint(equalTo: self.contentStackView.centerXAnchor)
        self.imageViewTrailing.translatesAutoresizingMaskIntoConstraints = false
        self.imageViewTrailing.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
        
        //Addition of the views
        switch self.imagePosition {
        case .leading:
            imageViewLeading.isHidden = false
            imageViewTrailing.isHidden = true
        case .trailing:
            imageViewLeading.isHidden = true
            imageViewTrailing.isHidden = false
        }
        self.contentStackView.addArrangedSubview(self.imageViewLeading)
        self.contentStackView.addArrangedSubview(self.titleLabel)
        self.contentStackView.addArrangedSubview(self.imageViewTrailing)
        self.addSubview(self.contentStackView)
        
        //Constraints
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|->=8-[contentStackView]->=8-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["contentStackView" : self.contentStackView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentStackView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["contentStackView" : self.contentStackView]))
        self.addConstraint(NSLayoutConstraint(item: self.contentStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.titleLabel.font = self.font
        
        if let key = self.titleLocalizationKey {
            self.titleLocalizationKey = key
        }
    }
    
    override public func draw(_ rect: CGRect) {
        (self.backgroundColor ?? UIColor.clear).set()
        
        var drawFrame : CGRect
        switch self.checkState {
        case .checked:
            self.selectedColor.set()
            drawFrame = self.bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
            let path = UIBezierPath(roundedRect: drawFrame, cornerRadius: (self.changeRadius ? CGFloat(self.cornerRadius) : drawFrame.height))
            path.lineWidth = CGFloat(self.borderWidth)
            path.stroke()
        case .unchecked:
            self.unSelectedColor.set()
            drawFrame = self.bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
            let path = UIBezierPath(roundedRect: drawFrame, cornerRadius: (self.changeRadius ? CGFloat(self.cornerRadius) : drawFrame.height))
            path.lineWidth = CGFloat(self.borderWidth)
            path.stroke()
        }
    }
    
    public func refreshUI() {
        self.setNeedsDisplay()
    }
    
    public func updateFrameSize() {
        self.titleLabel.sizeToFit()
        self.frame.size = CGSize.init(width: self.titleLabel.frame.size.width+self.offset.x*2, height: self.titleLabel.frame.size.height+self.offset.y*2)
    }
    
    @objc public func toggleCheckState() {
        self.delegate?.didTouchControl(sender: self)
        if case .unchecked = self.checkState {
            self.checkState = .checked
        }else {
            self.checkState = .unchecked
        }
    }
    public func uncheck() {
        self.checkState = .unchecked
    }
}
