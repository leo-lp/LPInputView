//
//  LPStretchyTextView+At.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

extension NSAttributedStringKey {
    static let LPAtUser = NSAttributedStringKey("com.lp.LPInputView.attributedString.atUser")
}

// MARK: - @用户insert/delete等操作

extension LPStretchyTextView {
    
    /// 向text里插入一个at用户
    func insertUser(withID id: Int, name: String, checkAt character: String?) {
        deleteSelectedCharacter()
        
        if let character = character {
            deleteAtCharacter(character)
        }
        
        let user = LPAtUser(id: id, name: name)
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: user.nameColor,
                                                        .LPAtUser: user]
        let userAttrString = NSAttributedString(string: user.atName, attributes: attributes)
        
        let mutableAttrString = NSMutableAttributedString()
        mutableAttrString.append(textAttrString("", checkAtUser: true))
        mutableAttrString.append(userAttrString)
        mutableAttrString.append(textAttrString(" ", checkAtUser: false))
        insertAttrString(mutableAttrString)
    }
    
    /// 删除At用户
    func deleteUser(in deleteRange: NSRange) -> Bool {
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
    func deleteCharacters() {
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
    }
    
    func textAttrString(_ string: String, checkAtUser isCheck: Bool) -> NSAttributedString {
        var string = string
        if isCheck && isAtUserOfPreviousCharacter {
            string.insert(" ", at: string.startIndex)
        }
        
        guard let color = originalTextColor else {
            return NSAttributedString(string: string)
        }
        return NSAttributedString(string: string, attributes: [.foregroundColor: color])
    }
    
    /// 检查光标是否在user区域
    func checkUserArea() {
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
