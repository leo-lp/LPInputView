//
//  LPStretchyTextView.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

@objc public protocol LPTextViewDelegate: UITextViewDelegate {
    /// 当textView文本改变之后调用
    @objc optional func textView(_ textView: UITextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int)
    
    /// 当textView高度改变之后调用
    @objc optional func textView(_ textView: UITextView, heightDidChange newHeight: CGFloat)
    
    /// 当textView输入@字符后调用
    @objc optional func textView(_ textView: UITextView, inputAtCharacter character: String)
}

open class LPStretchyTextView: UITextView, NSTextStorageDelegate {
    open weak var lpDelegate: LPTextViewDelegate?
    
    /// Placeholder TextView
    open var placeholder: NSAttributedString? { didSet { setNeedsDisplay() } }
    open private(set) var textIsEmpty: Bool = true { didSet { if textIsEmpty != oldValue { setNeedsDisplay() } } }
    
    /// Stretchy TextView
    open private(set) var maxHeight: CGFloat? // 限制输入框的最大高度
    open private(set) var minHeight: CGFloat? // 限制输入框的最小高度
    open override var contentSize: CGSize { didSet { resize() } }
    
    /// Emotion TextView
    open override var font: UIFont? { didSet { if originalFont != font { originalFont = font } } }
    open override var textColor: UIColor? { didSet { if originalTextColor != textColor { originalTextColor = textColor } } }
    private(set) var originalFont: UIFont?
    private(set) var originalTextColor: UIColor?
    
    deinit {
        #if DEBUG
        print("LPPStretchyTextView:-> release memory.")
        #endif
    }
    
    // MARK: - Placeholder TextView
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor.clear
        textStorage.delegate = self
        /// Emotion TextView
        layoutManager.allowsNonContiguousLayout = false
        originalFont = font
        originalTextColor = textColor
    }
    
    open override func draw(_ rect: CGRect) {
        guard textIsEmpty, let placeholder = placeholder else { return }
        
        let topInset = textContainerInset.top + contentInset.top
        let leftInset = textContainerInset.left + contentInset.left + 4.5
        let targetRect = CGRect(x: leftInset, y: topInset, width: frame.width - leftInset, height: frame.height - topInset)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let attr = NSMutableAttributedString(attributedString: placeholder)
        let allRange = NSRange(location: 0, length: attr.length)
        attr.addAttribute(.paragraphStyle, value: paragraphStyle, range: allRange)
        
        if attr.attribute(.font, at: 0, effectiveRange: nil) == nil, let font = font {
            attr.addAttribute(.font, value: font, range: allRange)
        }
        
        if attr.attribute(.foregroundColor, at: 0, effectiveRange: nil) == nil, let color = textColor {
            attr.addAttribute(.foregroundColor, value: color, range: allRange)
        }
        
        attr.draw(in: targetRect)
    }
    
    /// NSTextStorageDelegate
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        textIsEmpty = textStorage.length == 0
        lpDelegate?.textView?(self, didProcessEditing: editedRange, changeInLength: delta)
        /// Emotion TextView
        if textIsEmpty {
            font = originalFont
            textColor = originalTextColor
        }
    }
    
    // MARK: - Stretchy TextView
    
    /// 限制textView可输入的文本行数
    /// - Parameters:
    ///   - min: 最小行数
    ///   - max: 最大行数
    open func textLines(min: Int?, max: Int?) {
        guard let min = min, let max = max else {
            minHeight = nil
            maxHeight = nil
            return
        }
        minHeight = simulateHeight(min)
        maxHeight = simulateHeight(max)
        resize()
    }
    
    private func resize() {
        guard let minHeight = minHeight, let maxHeight = maxHeight else { return }
        
        let finalHeight = min(max(contentSize.height, minHeight), maxHeight)
        guard frame.height != finalHeight else { return }
        frame.size.height = finalHeight
        lpDelegate?.textView?(self, heightDidChange: finalHeight)
    }
    
    private func simulateHeight(_ numberOfLines: Int) -> CGFloat {
        /// 如果文本行数为<=0则限制高度为0.0
        guard numberOfLines > 0 else { return 0.0 }
        
        isHidden = true
        let saveText = text
        
        var newText = "|W|"
        for _ in 0..<numberOfLines-1 {
            newText += "\n|W|"
        }
        text = newText
        
        let size = sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        
        text = saveText
        isHidden = false
        return size.height
    }
    
    // MARK: - Emotion TextView
    
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
        selectedRange = NSRange(location: selectedRange.location + attrString.length, length: 0)
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
        guard let originalFont = originalFont, font != originalFont else { return }
        //let range = NSRange(location: 0, length: textStorage.length)
        //textStorage.removeAttribute(.font, range: range)
        //textStorage.addAttribute(.font, value: originalFont, range: range)
        font = originalFont
    }
    
    /// 滚动到TextView的底部
    public func scrollToBottom() {
        scrollRangeToVisible(NSRange(location: textStorage.length, length: 1))
    }
}
