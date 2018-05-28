//
//  LPEmotionTextView.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

open class LPEmotionTextView: LPStretchyTextView {
    
    open override var font: UIFont? {
        didSet {
            if originalFont != font { originalFont = font }
        }
    }
    
    open override var textColor: UIColor? {
        didSet {
            if originalTextColor != textColor { originalTextColor = textColor }
        }
    }
    
    private(set) var originalFont: UIFont?
    private(set) var originalTextColor: UIColor?
    
    // MARK: - Override funs
    
    deinit {
        #if DEBUG
        print("LPAtTextView:-> release memory.")
        #endif
    }
    
    override func commonInit() {
        super.commonInit()
        layoutManager.allowsNonContiguousLayout = false
        originalFont = font
        originalTextColor = textColor
    }
    
    open func insertEmotion(_ attachment: LPTextAttachment) {
        let attrString = NSAttributedString(attachment: attachment)
        let mutableAttrString = NSMutableAttributedString(attributedString: attrString)
        if let font = originalFont {
            let range = NSRange(location: 0, length: mutableAttrString.length)
            mutableAttrString.addAttribute(.font, value: font, range: range)
        }
        insertAttrString(mutableAttrString)
    }
    
    open func insertAttrString(_ attrString: NSAttributedString) {
        deleteSelectedCharacter()
        textStorage.insert(attrString, at: selectedRange.location)
        let location = selectedRange.location + attrString.length
        selectedRange = NSRange(location: location, length: 0)
        resetTextStyle()
        scrollToBottom()
    }
    
    open func deleteSelectedCharacter() {
        guard selectedRange.length > 0 else { return }
        textStorage.deleteCharacters(in: selectedRange)
        selectedRange = NSRange(location: selectedRange.location, length: 0)
    }
    
    open func deleteEmotion() {
        /// 删除选中的字符
        if selectedRange.length > 0 {
            textStorage.deleteCharacters(in: selectedRange)
            selectedRange = NSRange(location: selectedRange.location, length: 0)
        } else if selectedRange.location > 0 {
            let range = NSRange(location: selectedRange.location - 1, length: 1)
            textStorage.deleteCharacters(in: range)
            selectedRange = NSRange(location: range.location, length: 0)
        }
    }
    
    open func clearTextStorage() {
        let range = NSRange(location: 0, length: textStorage.length)
        textStorage.deleteCharacters(in: range)
        selectedRange = NSRange(location: 0, length: 0)
        resetTextStyle()
    }
    
    public func resetTextStyle() {
        guard let originalFont = originalFont
            , font != originalFont else { return }
//        let range = NSRange(location: 0, length: textStorage.length)
//        textStorage.removeAttribute(.font, range: range)
//        textStorage.addAttribute(.font, value: originalFont, range: range)
        font = originalFont
    }
    
    /// 滚动到TextView的底部
    public func scrollToBottom() {
        let range = NSRange(location: textStorage.length, length: 1)
        scrollRangeToVisible(range)
    }
}

extension LPEmotionTextView {
    
    public override func textStorage(_ textStorage: NSTextStorage,
                                     didProcessEditing editedMask: NSTextStorageEditActions,
                                     range editedRange: NSRange,
                                     changeInLength delta: Int) {
        super.textStorage(textStorage,
                          didProcessEditing: editedMask,
                          range: editedRange,
                          changeInLength: delta)
        if textIsEmpty {
            font = originalFont
            textColor = originalTextColor
        }
    }
}
