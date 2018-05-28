//
//  LPTextView+Pasteboard.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

extension LPEmotionTextView {
    
    open override func paste(_ sender: Any?) {
        guard let attrString = UIPasteboard.general.lp_attributedString
            , attrString.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString()
        mutableAttrString.append(attrString)
        
        if let font = originalFont {
            let range = NSRange(location: 0, length: mutableAttrString.length)
            mutableAttrString.addAttributes([.font : font], range: range)
        }
        
        insertAttrString(mutableAttrString)
    }
    
    open override func cut(_ sender: Any?) {
        guard selectedRange.length > 0 else { return }
        
        let attrString = textStorage.attributedSubstring(from: selectedRange)
       
        deleteSelectedCharacter()
       
        UIPasteboard.general.lp_attributedString = attrString
    }

    open override func copy(_ sender: Any?) {
        guard selectedRange.length > 0 else { return }
       
        let attrString = textStorage.attributedSubstring(from: selectedRange)
       
        UIPasteboard.general.lp_attributedString = attrString
    }
}

extension LPAtTextView {
    
    open override func paste(_ sender: Any?) {
        guard let attrString = UIPasteboard.general.lp_attributedString
            , attrString.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString()
        mutableAttrString.append(textAttrString("", checkAtUser: true))
        mutableAttrString.append(attrString)
        
        if let font = originalFont {
            let range = NSRange(location: 0, length: mutableAttrString.length)
            mutableAttrString.addAttributes([.font : font], range: range)
        }
        
        insertAttrString(mutableAttrString)
        
        if isAtUserOfPreviousCharacter && !isSpaceOfLatterCharacter {
            insertAttrString(textAttrString(" ", checkAtUser: false))
        }
    }
}
