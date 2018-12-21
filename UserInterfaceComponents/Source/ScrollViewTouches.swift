//
//  ScrollViewTouches.swift
//  UserInterfaceComponents
//
//  Created by Guillaume Bourachot on 20/12/2018.
//  Copyright © 2018 Guillaume Bourachot. All rights reserved.
//

import Foundation
import UIKit

class ScrollViewTouches : UIScrollView {
    
    var editableFrame : CGRect = CGRect.zero
    var containerView : UIView?
    var completionHandler : (() -> ())?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let parentView = self.containerView, let location = touch?.location(in: parentView) else { return }
        if !self.editableFrame.contains(location) {
            self.completionHandler?()
        }
        
    }
    
}
