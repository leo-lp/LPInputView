//
//  LPAtTextView.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

open class LPAtTextView: LPEmotionTextView {
    
    open override var delegate: UITextViewDelegate? {
        didSet {
            guard let delegate = delegate
                , !(delegate is LPAtTextView) else { return }
            fatalError("delegate不可用，请使用LPAtTextView.tvDelegate")
        }
    }
    
    /// 是否启用“@”功能
    open var isAtEnabled: Bool = false
    
    // MARK: - Override funs
    
    deinit {
        #if DEBUG
        print("LPAtTextView:-> release memory.")
        #endif
    }
    
    override func commonInit() {
        super.commonInit()
        delegate = self
    }
    
    /// 插入一个at用户
    public func insertUser(withID id: Int, name: String, checkAt character: String?) {
        guard isAtEnabled else { return }
        
        deleteSelectedCharacter()
        
        if let character = character {
            deleteAtCharacter(character)
        }
        
        let user = LPAtUser(id: id, name: name)
        var attributes: [NSAttributedStringKey: Any] = [.foregroundColor: user.nameColor,
                                                        .LPAtUser: user]
        if let font = originalFont {
            attributes[.font] = font
        }
        let userAttrString = NSAttributedString(string: user.atName, attributes: attributes)
        
        let mutableAttrString = NSMutableAttributedString()
        mutableAttrString.append(textAttrString("", checkAtUser: true))
        mutableAttrString.append(userAttrString)
        mutableAttrString.append(textAttrString(" ", checkAtUser: false))
        insertAttrString(mutableAttrString)
    }
    
    /// 删除At用户
    public func deleteUser(in deleteRange: NSRange) -> Bool {
        guard deleteRange.location > 0 else { return false }
        
        var isDeleted = false
        let key = NSAttributedStringKey.LPAtUser
        let searchRange = NSRange(location: 0, length: textStorage.length)
        let options = NSAttributedString.EnumerationOptions.reverse
        textStorage.enumerateAttribute(key, in: searchRange, options: options) { (obj, range, stop) in
            guard obj is LPAtUser else { return }
            
            if deleteRange.location >= range.location && deleteRange.location <= range.upperBound - 1 {
                stop.pointee = true // 找到需要删除的user，强制停止enumerateAttribute函数的执行
                isDeleted = true
                
                self.textStorage.deleteCharacters(in: range)
                self.selectedRange = NSRange(location: range.location, length: 0)
            }
        }
        return isDeleted
    }
    
    /// 删除字符（注：包括At用户 和 emotion表情）
    public func deleteCharacters() {
        if isAtEnabled {
            if selectedRange.length > 0 {
                if !deleteUser(in: selectedRange) {
                    deleteEmotion()
                }
            } else if selectedRange.location > 0 {
                let range = NSRange(location: selectedRange.location - 1, length: 1)
                if !deleteUser(in: range) {
                    deleteEmotion()
                }
            }
        } else {
            deleteEmotion()
        }
    }
    
    public func textAttrString(_ string: String, checkAtUser isCheck: Bool) -> NSAttributedString {
        var string = string
        
        if isCheck && isAtUserOfPreviousCharacter {
            string.insert(" ", at: string.startIndex)
        }
        
        guard let color = originalTextColor, let font = originalFont else {
            return NSAttributedString(string: string)
        }
        
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: color,
                                                        .font: font]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    /// 检查光标是否在user区域
    private func checkUserAreaAndAutoSelected() {
        let key = NSAttributedStringKey.LPAtUser
        let searchRange = NSRange(location: 0, length: textStorage.length)
        let options = NSAttributedString.EnumerationOptions.reverse
        textStorage.enumerateAttribute(key, in: searchRange, options: options) { (obj, range, stop) in
            guard obj is LPAtUser else { return }
            
            let selRange = self.selectedRange
            /// 当光标停留在user区域
            if (selRange.location > range.location && selRange.location < range.upperBound)
                || (selRange.location == range.location && selRange.length > 0 && selRange.length < range.length)
                || (selRange.location < range.location && selRange.upperBound > range.lowerBound && selRange.upperBound <= range.upperBound) {
                stop.pointee = true // 找到user，强制停止enumerateAttribute函数的执行
                self.selectedRange = range
            }
        }
    }
    
    var isAtUserOfPreviousCharacter: Bool {
        guard selectedRange.location > 0 else { return false }
        let key = NSAttributedStringKey.LPAtUser
        let loc = selectedRange.location - 1
        return textStorage.attribute(key, at: loc, effectiveRange: nil) is LPAtUser
    }
    
    var isAtUserOfLatterCharacter: Bool {
        guard selectedRange.length == 0
            , textStorage.length > selectedRange.location else { return false }
        
        let key = NSAttributedStringKey.LPAtUser
        let loc = selectedRange.location
        return textStorage.attribute(key, at: loc, effectiveRange: nil) is LPAtUser
    }
    
    var isSpaceOfLatterCharacter: Bool {
        guard selectedRange.length == 0
            , textStorage.length > selectedRange.location else { return false }
        
        let range = NSRange(location: selectedRange.location, length: 1)
        return textStorage.attributedSubstring(from: range).string == " "
    }
    
    private func deleteAtCharacter(_ character: String) {
        let count = character.count
        guard count > 0
            , selectedRange.location >= count
            , textStorage.length > selectedRange.location - count else { return }
        
        let range = NSRange(location: selectedRange.location - count, length: count)
        let subChar = textStorage.attributedSubstring(from: range)
        if subChar.string == character {
            textStorage.deleteCharacters(in: range)
            selectedRange = NSRange(location: range.location, length: 0)
        }
    }
}

// MARK: -
// MARK: - UITextViewDelegate

extension LPAtTextView: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let flag = tvDelegate?.textViewShouldBeginEditing?(textView)
            , !flag { return flag }
        if isAtEnabled {
            checkUserAreaAndAutoSelected()
        }
        return true
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return tvDelegate?.textViewShouldEndEditing?(textView) ?? true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        tvDelegate?.textViewDidBeginEditing?(textView)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        tvDelegate?.textViewDidEndEditing?(textView)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let flag = tvDelegate?.textView?(textView,
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
            if let tvDelegate = tvDelegate {
                tvDelegate.textView?(self, inputAtCharacter: text)
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
        tvDelegate?.textViewDidChange?(textView)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        tvDelegate?.textViewDidChangeSelection?(textView)
        if isAtEnabled {
            checkUserAreaAndAutoSelected()
        }
    }
    
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView,
                         shouldInteractWith URL: URL,
                         in characterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {
        return tvDelegate?.textView?(textView,
                                     shouldInteractWith: URL,
                                     in: characterRange,
                                     interaction: interaction) ?? true
    }
    
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView,
                         shouldInteractWith textAttachment: NSTextAttachment,
                         in characterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {
        return tvDelegate?.textView?(textView,
                                     shouldInteractWith: textAttachment,
                                     in: characterRange,
                                     interaction: interaction) ?? true
    }
}
