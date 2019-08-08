//
//  UIApplication+LPKit.swift
//  LPKit <https://github.com/leo-lp/LPKit>
//
//  Created by pengli on 2018/5/21.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit.UIApplication

public extension UIApplication {
    
    var lp_currWindow: UIWindow? {
        return keyWindow ?? windows.first
    }
    
    var lp_safeAreaInsets: UIEdgeInsets {
        guard #available(iOS 11.0, *)
            , let window = lp_currWindow else { return .zero }
        return window.safeAreaInsets
    }
    
}
