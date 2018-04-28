//
//  UIPasteboard+LPInputView.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

extension UIPasteboard {
    static let LPPasteboardAttributedString: String = "com.lp.LPInputView.pasteboard.attributedString"
    
    /// 为UIPasteboard扩展粘贴富文本功能
    /// 注：富文本主要包含LPTextAttachment和@用户
    var lp_attributedString: NSAttributedString? {
        get {
            for item in items {
                if let data = item[UIPasteboard.LPPasteboardAttributedString] as? Data
                    , let attrString = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSAttributedString {
                    return LPEmotion.shared.attrString(with: attrString, scale: 1.0, font: nil)
                }
            }
            guard let string = string else { return nil }
            return LPEmotion.shared.attrString(with: string, scale: 1.0, font: nil)
        }
        
        set {
            guard let newValue = newValue else { return }
            let attrString = newValue.lp_parseEmotion().attrString
            
            string = attrString.string
            
            let data = NSKeyedArchiver.archivedData(withRootObject: attrString)
            addItems([[UIPasteboard.LPPasteboardAttributedString: data]])
        }
    }
}
