//
//  LPStretchyTextView+Pasteboard.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPInputView

extension LPStretchyTextView {
    
    override open func paste(_ sender: Any?) {
        guard let attrString = UIPasteboard.general.lp_attributedString else { return }
        let mutableAttrString = NSMutableAttributedString()
        mutableAttrString.append(textAttrString("", checkAtUser: true))
        mutableAttrString.append(attrString)
        if let font = originalTextFont {
            let range = NSRange(location: 0, length: mutableAttrString.length)
            mutableAttrString.addAttributes([.font : font], range: range)
        }
        insertAttrString(mutableAttrString)
    }
    
    override open func cut(_ sender: Any?) {
        guard selectedRange.length > 0 else { return }
        let attrString = textStorage.attributedSubstring(from: selectedRange)
        deleteSelectedCharacter()
        UIPasteboard.general.lp_attributedString = attrString
    }
    
    override open func copy(_ sender: Any?) {
        guard selectedRange.length > 0 else { return }
        let attrString = textStorage.attributedSubstring(from: selectedRange)
        UIPasteboard.general.lp_attributedString = attrString
    }
}
