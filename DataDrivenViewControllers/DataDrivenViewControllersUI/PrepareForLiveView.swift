//
//  PrepareForLiveView.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/18/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import Foundation
import UIKit


public enum ScreenType: RawRepresentable {
    case iPhoneSE
    case iPhone6
    case iPhone7Plus
    case iPhoneX
    
    public typealias RawValue = CGSize
    
    public init?(rawValue: ScreenType.RawValue) {
        switch rawValue {
        case CGSize(width: 320, height: 568):
            self = .iPhoneSE
        case CGSize(width: 375, height: 667):
            self = .iPhone6
        case CGSize(width: 414, height: 736):
            self = .iPhone7Plus
        case CGSize(width: 375, height: 812):
            self = .iPhoneX
        default:
            return nil
        }
    }
    
    public var rawValue: CGSize {
        switch self {
        case .iPhoneSE:
            return CGSize(width: 320, height: 568)
        case .iPhone6:
            return CGSize(width: 375, height: 667)
        case .iPhone7Plus:
            return CGSize(width: 414, height: 736)
        case .iPhoneX:
            return CGSize(width: 375, height: 812)
        }
    }
}

public func prepareForLiveView<VC: UIViewController>(
    screenType: ScreenType,
    scale: CGFloat = 1.0,
    isPortrait: Bool = true,
    viewController: VC
) -> (UIWindow, VC) {
    let size = CGSize(width: screenType.rawValue.width * scale, height: screenType.rawValue.height * scale)
    let window = UIWindow(frame: CGRect(origin: .zero, size: isPortrait ? size : CGSize(width: size.height, height: size.width)))
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    return (window, viewController)
}

