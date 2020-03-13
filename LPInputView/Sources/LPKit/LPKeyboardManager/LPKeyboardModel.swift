//
//  LPKeyboardModel.swift
//  LPKeyboardManager <https://github.com/leo-lp/LPKeyboardManager>
//
//  Created by pengli on 2018/5/17.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public struct LPKeyboardTransition {
    public var fromVisible: Bool = false
    public var toVisible: Bool = false
    
    public var fromFrame: CGRect = .zero
    public var toFrame: CGRect = .zero
    
    public var animationDuration: TimeInterval = 0
    public var animationCurve: UIView.AnimationCurve = .easeInOut
    public var animationOption: UIView.AnimationOptions = .curveEaseInOut
    
    public var safeAreaInsets: UIEdgeInsets = .zero
}

extension LPKeyboardTransition: CustomStringConvertible {
    public var description: String {
        let str: String =
        """
        fromVisible=\(fromVisible)
        toVisible=\(toVisible)
        fromFrame=\(fromFrame)
        toFrame=\(toFrame)
        animationDuration=\(animationDuration)
        animationCurve=\(animationCurve.rawValue)
        animationOption=\(animationOption.rawValue)
        safeAreaInsets=\(safeAreaInsets)
        """
        return str
    }
}
