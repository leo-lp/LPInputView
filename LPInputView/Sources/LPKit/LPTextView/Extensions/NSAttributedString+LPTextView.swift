//
//  NSAttributedString+LPTextView.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
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
        result.users = users
        return result
    }
    
    /// 检索属性字符串，将其富文本转化为纯文本占位符
    func lp_parseEmotion() -> LPParseResult {
        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        var emotionCount = 0
        var emotions: [String: LPEmotion] = [:]
        
        /// 检索LPTextAttachment
        let key = NSAttributedStringKey.attachment
        let allRange = NSRange(location: 0, length: mutableAttrString.length)
        let options = NSAttributedString.EnumerationOptions.reverse
        mutableAttrString.enumerateAttribute(key, in: allRange, options: options) { (obj, range, stop) in
            if let attachment = obj as? LPTextAttachment, let tagName = attachment.tagName {
                mutableAttrString.removeAttribute(key, range: range)
                
                let attributes = [NSAttributedStringKey.LPEmotionID: tagName]
                let attrString = NSAttributedString(string: tagName,
                                                    attributes: attributes)
                mutableAttrString.replaceCharacters(in: range, with: attrString)
                emotionCount += 1
                emotions[tagName] = LPEmotion(with: attachment)
            }
        }
        
        return LPParseResult(attrString: mutableAttrString,
                             emotionCount: emotionCount,
                             emotions: emotions,
                             users: nil)
    }
}

// MARK: -
// MARK: - 正则表达式

public extension NSAttributedString {
    
    /// 用正则表达式解析Emotion
    ///
    /// - Parameters:
    ///   - pattern: 匹配模式
    ///   - replaceBlock: 在Block里把匹配到的字符串替换成你想要的NSAttributedString，如果不想替换则返回nil
    /// - Returns: 匹配替换完成后的字符串
    func lp_regex(pattern: String, replaceBlock: (_ checkingResult: NSAttributedString) -> NSAttributedString) -> NSMutableAttributedString? {
        do {
            let exp = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            let mutableAttrString = NSMutableAttributedString(attributedString: self)
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
        return nil
    }
}
