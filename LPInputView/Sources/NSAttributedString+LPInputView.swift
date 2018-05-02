//
//  NSAttributedString+LPInputView.swift
//  LPInputView
//
//  Created by pengli on 2018/4/28.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public extension NSAttributedString {

    func lp_parse(_ atUserPlaceholderByBlock: (_ index: Int, _ user: LPAtUser) -> String) -> LPParseResult {
        let mutableAttrString = NSMutableAttributedString(attributedString: self)

        /// 解析@用户
        var users: [(placeholder: String, user: LPAtUser)] = []
        let key = NSAttributedStringKey.LPAtUser
        let range = NSRange(location: 0, length: length)
        let options = NSAttributedString.EnumerationOptions.reverse
        mutableAttrString.enumerateAttribute(key, in: range, options: options) { (obj, range, stop) in
            guard let user = obj as? LPAtUser else { return }
            let placeholder = atUserPlaceholderByBlock(users.count, user)
            mutableAttrString.removeAttribute(key, range: range)
            mutableAttrString.replaceCharacters(in: range, with: placeholder)
            users.append((placeholder, user))
        }

        /// 解析Emotion
        var result = mutableAttrString.lp_parseEmotion()
        result.user = users
        return result
    }

    /// 检索属性字符串，将其富文本转化为纯文本占位符
    func lp_parseEmotion() -> LPParseResult {
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        var emotionCount = 0

        /// 检索LPTextAttachment
        let key = NSAttributedStringKey.attachment
        let allRange = NSRange(location: 0, length: mutableAttrString.length)
        let options = NSAttributedString.EnumerationOptions.reverse
        mutableAttrString.enumerateAttribute(key, in: allRange, options: options) { (obj, range, stop) in
            if let attachment = obj as? LPTextAttachment, let tagName = attachment.tagName {
                mutableAttrString.removeAttribute(key, range: range)
                mutableAttrString.replaceCharacters(in: range, with: tagName)
                emotionCount += 1
            }
        }

        return LPParseResult(attrString: mutableAttrString,
                             emotionCount: emotionCount,
                             user: nil)
    }
}

// MARK: - 正则表达式

public extension NSAttributedString {
    
    /// 用正则表达式解析emotion
    ///
    /// - Parameters:
    ///   - pattern: 匹配模式
    ///   - replaceBlock: 匹配替换符号：把匹配到的字符串替换成你想要的NSAttributedString，如果不想替换则返回nil
    /// - Returns: 匹配替换完成后的字符串
    func lp_regex(pattern: String, replaceBlock: (_ checkingResult: NSAttributedString) -> NSAttributedString) -> NSMutableAttributedString {
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        do {
            let exp = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let string = mutableAttrString.string
            let options = NSRegularExpression.MatchingOptions(rawValue: 0)
            let range = NSRange(location: 0, length: mutableAttrString.length)
            
            let resultAttrString = NSMutableAttributedString()
            var index: Int = 0
            exp.enumerateMatches(in: string, options: options, range: range) { (result, flags, stop) in
                if let result = result {
                    if result.range.location > index {
                        let range = NSRange(location: index, length: result.range.location - index)
                        let rangeString = mutableAttrString.attributedSubstring(from: range)
                        resultAttrString.append(rangeString)
                    }
                    
                    let rangeString = mutableAttrString.attributedSubstring(from: result.range)
                    resultAttrString.append(replaceBlock(rangeString))
                    
                    index = result.range.location + result.range.length
                }
            }
            
            if index < mutableAttrString.length {
                let range = NSRange(location: index, length: mutableAttrString.length - index)
                let rangeString = mutableAttrString.attributedSubstring(from: range)
                resultAttrString.append(rangeString)
            }
            
            return resultAttrString
        } catch {
            print(error)
        }
        
        return mutableAttrString
    }
}
