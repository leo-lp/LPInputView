//
//  LPStretchyTextView+Emotion.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

//public extension LPStretchyTextView {
//    
//    func insertEmotion(_ attachment: NSTextAttachment) {
//        let attrString = NSAttributedString(attachment: attachment)
//        let mutableAttrString = NSMutableAttributedString(attributedString: attrString)
//        if let font = originalTextFont {
//            let range = NSRange(location: 0, length: mutableAttrString.length)
//            mutableAttrString.addAttribute(.font, value: font, range: range)
//        }
//        insertAttrString(mutableAttrString)
//    }
//    
//    func insertAttrString(_ attrString: NSAttributedString) {
//        deleteSelectedCharacter()
//        textStorage.insert(attrString, at: selectedRange.location)
//        selectedRange = NSRange(location: selectedRange.location + attrString.length, length: 0)
//        resetTextStyle()
//        scrollToBottom()
//    }
//    
//    func deleteSelectedCharacter() {
//        guard selectedRange.length > 0 else { return }
//        textStorage.deleteCharacters(in: selectedRange)
//        selectedRange = NSRange(location: selectedRange.location, length: 0)
//    }
//    
//    func deleteEmotion() {
//        /// 删除选中的字符
//        if selectedRange.length > 0 {
//            textStorage.deleteCharacters(in: selectedRange)
//            selectedRange = NSRange(location: selectedRange.location, length: 0)
//        } else if selectedRange.location > 0 {
//            let range = NSRange(location: selectedRange.location - 1, length: 1)
//            textStorage.deleteCharacters(in: range)
//            selectedRange = NSRange(location: range.location, length: 0)
//        }
//    }
//    
//    /// 清空text
//    func clearTextStorage() {
//        textStorage.deleteCharacters(in: NSRange(location: 0, length: textStorage.length))
//        selectedRange = NSRange(location: 0, length: 0)
//        resetTextStyle()
//    }
//    
//    func resetTextStyle() {
//        guard let originalFont = originalTextFont, font != originalFont else { return }
//        let range = NSRange(location: 0, length: textStorage.length)
//        textStorage.removeAttribute(.font, range: range)
//        textStorage.addAttribute(.font, value: originalFont, range: range)
//    }
//    
//    func scrollToBottom() {
//        scrollRangeToVisible(NSRange(location: textStorage.length, length: 1))
//    }
//}
