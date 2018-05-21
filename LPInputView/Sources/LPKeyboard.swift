//
//  LPKeyboard.swift
//  LPInputView <https://github.com/leo-lp/LPInputView>
//
//  Created by 李鹏 on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

extension Notification.Name {
    static let LPKeyboardWillChangeFrame = Notification.Name(rawValue: "com.lp.LPInputView.notification.keyboardWillChangeFrame")
    static let LPKeyboardWillHide = Notification.Name(rawValue: "com.lp.LPInputView.notification.keyboardWillHide")
}

class LPKeyboard {
    static let shared: LPKeyboard = { return LPKeyboard() }()
    
    /// 是否可见
    private(set) var isVisiable: Bool = false
    
    /// 键盘高
    private(set) var height: CGFloat = 0.0
    
    lazy var safeAreaInsets: UIEdgeInsets = {
        guard #available(iOS 11.0, *)
            , let window = UIApplication.shared.keyWindow else { return .zero }
        return window.safeAreaInsets
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardWillChangeFrame),
                           name: .UIKeyboardWillChangeFrame,
                           object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo
            , let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            , let window = UIApplication.shared.keyWindow else { return }
        let endFrame = endFrameValue.cgRectValue
        
        isVisiable = endFrame.origin.y != window.frame.height
        height = isVisiable ? endFrame.height : 0.0
        
        NotificationCenter.default.post(name: .LPKeyboardWillChangeFrame,
                                        object: nil,
                                        userInfo: notification.userInfo)
    }
}
