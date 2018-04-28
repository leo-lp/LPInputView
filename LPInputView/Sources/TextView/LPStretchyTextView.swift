//
//  LPStretchyTextView.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

@objc public protocol LPStretchyTextViewDelegate: UITextViewDelegate {
    /// 当textView文本改变之后调用
    @objc optional func textView(_ textView: LPStretchyTextView,
                                 didProcessEditing editedRange: NSRange,
                                 changeInLength delta: Int)
    /// 当textView高度改变之后调用
    @objc optional func textView(_ textView: LPStretchyTextView, heightDidChange newHeight: CGFloat)
    /// 当textView输入@字符后调用
    @objc optional func textView(_ textView: LPStretchyTextView, inputAtCharacter character: String)
}

public class LPStretchyTextView: UITextView {
    public weak var stretchyDelegate: LPStretchyTextViewDelegate?
    public var isAtEnabled: Bool = false
    
    /// 限制输入框可输入的最小行数
    public var minNumberOfLines: Int? {
        didSet {
            if let newValue = minNumberOfLines {
                if newValue <= 0 { return minHeight = 0 }
                minHeight = simulateHeight(newValue)
            } else {
                minHeight = nil
            }
        }
    }
    
    /// 限制输入框可输入的最大行数
    public var maxNumberOfLines: Int? {
        didSet {
            if let newValue = maxNumberOfLines {
                if newValue <= 0 { return maxHeight = 0 }
                maxHeight = simulateHeight(newValue)
            } else {
                maxHeight = nil
            }
        }
    }
    
    public var placeholder: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    
    public private(set) var originalTextFont: UIFont?
    public private(set) var originalTextColor: UIColor?
    
    private var maxHeight: CGFloat? // 限制输入框的最大高度
    private var minHeight: CGFloat? // 限制输入框的最小高度
    
    private var isDisplayPlaceholder: Bool = true {
        didSet { if isDisplayPlaceholder != oldValue { setNeedsDisplay() } }
    }
    
    // MARK: - Override
    
    deinit {
        print("LPStretchyTextView: -> release memory.")
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override var delegate: UITextViewDelegate? {
        didSet {
            guard let delegate = delegate, !(delegate is LPStretchyTextView) else { return }
            fatalError("禁止使用delegate，请使用LPStretchyTextView.stretchyDelegate.")
        }
    }
    
    public override var contentSize: CGSize {
        didSet { resize() }
    }
    
    public override var font: UIFont? {
        didSet { if originalTextFont != font { originalTextFont = font } }
    }
    
    public override var textColor: UIColor? {
        didSet { if originalTextColor != textColor { originalTextColor = textColor } }
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(copy(_:)),
             #selector(selectAll(_:)),
             #selector(cut(_:)),
             #selector(select(_:)),
             #selector(paste(_:)):
            return super.canPerformAction(action, withSender: sender)
        default:
            return false
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard isDisplayPlaceholder
            , let placeholder = placeholder else { return }
        
        let topInset = textContainerInset.top + contentInset.top
        let leftInset = textContainerInset.left + contentInset.left + 4.5
        let targetRect = CGRect(x: leftInset,
                                y: topInset,
                                width: frame.width - leftInset,
                                height: frame.height - topInset)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        let attr = NSMutableAttributedString(attributedString: placeholder)
        let allRange = NSRange(location: 0, length: attr.length)
        attr.addAttribute(.paragraphStyle,
                          value: paragraphStyle,
                          range: allRange)
        if attr.attribute(.font, at: 0, effectiveRange: nil) == nil
            , let font = originalTextFont {
            attr.addAttribute(.font, value: font, range: allRange)
        }
        if attr.attribute(.foregroundColor, at: 0, effectiveRange: nil) == nil
            , let color = originalTextColor {
            attr.addAttribute(.foregroundColor, value: color, range: allRange)
        }
        attr.draw(in: targetRect)
    }
}

// MARK: - Private Funcs

extension LPStretchyTextView {
    
    private func commonInit() {
        backgroundColor = UIColor.clear
        layoutManager.allowsNonContiguousLayout = false
        delegate = self
        textStorage.delegate = self
        
        originalTextFont = font
        originalTextColor = textColor
    }
    
    private func resize() {
        guard let minHeight = minHeight
            , let maxHeight = maxHeight else { return }
        
        let finalHeight = min(max(contentSize.height, minHeight), maxHeight)
        if frame.size.height != finalHeight {
            frame.size.height = finalHeight
            stretchyDelegate?.textView?(self, heightDidChange: finalHeight)
        }
    }
    
    private func simulateHeight(_ line: Int) -> CGFloat {
        isHidden = true
        let saveText = text
        
        var newText = "|W|"
        for _ in 0..<line-1 {
            newText += "\n|W|"
        }
        text = newText
        
        let height = sizeThatFits(CGSize(width: bounds.width,
                                         height: CGFloat.greatestFiniteMagnitude)).height
        
        text = saveText
        isHidden = false
        return height
    }
}

extension LPStretchyTextView: NSTextStorageDelegate {
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        isDisplayPlaceholder = textStorage.length == 0
        if isDisplayPlaceholder {
            textColor = originalTextColor
        }
        
        stretchyDelegate?.textView?(self,
                                    didProcessEditing: editedRange,
                                    changeInLength: delta)
    }
}

// MARK: -
// MARK: - LPAtTextView

extension LPStretchyTextView: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let flag = stretchyDelegate?.textViewShouldBeginEditing?(textView)
            , !flag { return flag }
        if isAtEnabled {
            checkUserAreaAndAutoSelected()
        }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return stretchyDelegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        stretchyDelegate?.textViewDidBeginEditing?(textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        stretchyDelegate?.textViewDidEndEditing?(textView)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let flag = stretchyDelegate?.textView?(textView,
                                                  shouldChangeTextIn: range,
                                                  replacementText: text)
            , !flag { return flag }
        
        guard isAtEnabled else { return true }
        
        switch text {
        case "": // 删除
            if range.length == 1 {
                return !deleteUser(in: range) // 非选择删除
            }
            return true // 选择删除
        case " ", "\n": // 输入空格 和 回车键
            if textColor != originalTextColor {
                insertAttrString(textAttrString(text, checkAtUser: false))
                return false
            }
            return true
        case LPAtUser.AtCharacter: // 输入@符
            if let stretchyDelegate = stretchyDelegate {
                stretchyDelegate.textView?(self, inputAtCharacter: text)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.insertAttrString(self.textAttrString(text, checkAtUser: true))
                }
            } else {
                insertAttrString(textAttrString(text, checkAtUser: true))
            }
            return false
        default: // 输入其他字符
            /// 在文本开头插入字符
            if range.location == 0 && isAtUserOfLatterCharacter {
                /// 如果在插入位置的后面一个字符为@，则将字符颜色恢复到原text颜色
                insertAttrString(textAttrString(text, checkAtUser: false))
                return false
            }
            
            if isAtUserOfPreviousCharacter {
                insertAttrString(textAttrString(" " + text, checkAtUser: false))
                return false
            } else if range.location == 0 && textStorage.length == 0 && originalTextColor != textColor {
                insertAttrString(textAttrString(text, checkAtUser: false))
                return false
            }
            
            return true
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        stretchyDelegate?.textViewDidChange?(textView)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        stretchyDelegate?.textViewDidChangeSelection?(textView)
        if isAtEnabled {
            checkUserAreaAndAutoSelected()
        }
    }
    
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return stretchyDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }
    
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return stretchyDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }
}
