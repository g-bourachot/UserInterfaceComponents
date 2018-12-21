//
//  CopyableLabel.swift
//  UserInterfaceComponents
//
//  Created by Guillaume Bourachot on 20/12/2018.
//  Copyright © 2018 Guillaume Bourachot. All rights reserved.
//

import Foundation
import UIKit

public class CopyableLabel : UILabel {
    
    override public var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }
    
    override public func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc public func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
}
