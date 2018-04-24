//
//  LPCustomView.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/19.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPCustomView: UIView {
    deinit {
        print("LPCustom: -> release memory.")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 216.0)
    }
}
