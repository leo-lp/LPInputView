//
//  LPKeyboard.swift
//  LPInputView
//
//  Created by 李鹏 on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
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
    
    /// 键盘高度
    private(set) var keyboardHeight: CGFloat = 0.0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardWillChangeFrame),
                           name: .UIKeyboardWillChangeFrame,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(keyboardWillChangeFrame),
                           name: .UIKeyboardWillHide,
                           object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo
            , let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            , let keyWindow = UIApplication.shared.keyWindow else { return }
        isVisiable = endFrame.origin.y != keyWindow.frame.height
        keyboardHeight = isVisiable ? endFrame.height : 0.0
        
        NotificationCenter.default.post(name: .LPKeyboardWillChangeFrame,
                                        object: nil,
                                        userInfo: notification.userInfo)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        isVisiable = false
        keyboardHeight = 0.0
        NotificationCenter.default.post(name: .LPKeyboardWillHide,
                                        object: nil,
                                        userInfo: notification.userInfo)
    }
}
