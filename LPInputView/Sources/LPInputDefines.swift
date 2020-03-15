//
//  LPInputDefines.swift
//  LPInputView <https://github.com/leo-lp/LPInputView>
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public enum LPInputBarItemType: Hashable {
    case text    // 文本输入框
    case emotion // 表情贴图
    case more    // 更多菜单
    case at      // @好友
    case custom(tag: UInt32)  // 定制item视图
    
    var rawValue: Int {
        switch self {
        case .text:            return 1000
        case .emotion:         return 1001
        case .more:            return 1002
        case .at:              return 1003
        case .custom(let tag): return 1004 + Int(tag)
        }
    }
    
    init(rawValue: Int) {
        switch rawValue {
        case 1000: self = .text
        case 1001: self = .emotion
        case 1002: self = .more
        case 1003: self = .at
        default:   self = .custom(tag: UInt32(rawValue - 1004))
        }
    }
}

public enum LPInputSeparatorLocation {
    case top
    case bottom
}
