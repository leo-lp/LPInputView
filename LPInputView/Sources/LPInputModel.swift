//
//  LPInputModel.swift
//  LPInputView <https://github.com/leo-lp/LPInputView>
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public struct LPInputToolBarItemType: OptionSet, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none    = LPInputToolBarItemType.text
    
    /// 录音切换按钮
    public static let voice   = LPInputToolBarItemType(rawValue: 1 << 1)
    
    /// @好友
    public static let at      = LPInputToolBarItemType(rawValue: 1 << 2)
    
    /// 文本输入框
    public static let text    = LPInputToolBarItemType(rawValue: 1 << 3)
    
    /// 表情贴图
    public static let emotion = LPInputToolBarItemType(rawValue: 1 << 4)
    
    /// 更多菜单
    public static let more    = LPInputToolBarItemType(rawValue: 1 << 5)
}

public enum LPInputSeparatorLocation {
    case top
    case bottom
}
