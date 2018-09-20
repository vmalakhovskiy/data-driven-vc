//
//  UIViewExtensions.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/18/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import UIKit

public extension UIView {
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    public func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0@999-[subview]-0@999-|",
                options: [],
                metrics: nil,
                views: ["subview": self]
            )
        )
        superview.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0@999-[subview]-0@999-|",
                options: [],
                metrics: nil,
                views: ["subview": self]
            )
        )
    }
}
