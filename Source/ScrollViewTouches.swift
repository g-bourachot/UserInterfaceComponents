//
//  ScrollViewTouches.swift
//  UserInterfaceComponents
//
//  Created by Guillaume Bourachot on 20/12/2018.
//  Copyright © 2018 Guillaume Bourachot. All rights reserved.
//

import Foundation
import UIKit

public class ScrollViewTouches : UIScrollView {
    
    public var editableFrame : CGRect = CGRect.zero
    public var containerView : UIView?
    public var completionHandler : (() -> ())?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let parentView = self.containerView, let location = touch?.location(in: parentView) else { return }
        if !self.editableFrame.contains(location) {
            self.completionHandler?()
        }
        
    }
    
}
