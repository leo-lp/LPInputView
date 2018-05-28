//
//  LPTextViewDelegate.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit.UITextView

@objc public protocol LPTextViewDelegate: UITextViewDelegate {
    
    /// 当textView文本改变之后调用
    @objc optional func textView(_ textView: UITextView,
                                 didProcessEditing editedRange: NSRange,
                                 changeInLength delta: Int)
    
    /// 当textView高度改变之后调用
    @objc optional func textView(_ textView: UITextView,
                                 heightDidChange newHeight: CGFloat)
    
    /// 当textView输入@字符后调用
    @objc optional func textView(_ textView: UITextView,
                                 inputAtCharacter character: String)
}
