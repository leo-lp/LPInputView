/**
 *  @file        LPEmotion.swift
 *  @project     LPInputView
 *  @brief
 *  @author      Lipeng
 *  @date        15/11/2 下午8:15
 *  @version     1.0
 *  @note
 *
 *  Copyright © 2018年 pengli. All rights reserved.
 */

import UIKit
import LPInputView

typealias LPEmotionID = String
class LPEmotion {
    static var shared : LPEmotion = { return LPEmotion() }()
    
    lazy var emojis: [String: String] = {
        guard let path = Bundle.main.path(forResource: "LPEmotion", ofType: "plist")
            , let emojis = NSDictionary(contentsOfFile: path) as? [String: String]
            else { return [:] }
        return emojis
    }()
        
    private let regulaPattern = "\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
    
    func emoji(by id: LPEmotionID) -> UIImage? {
        guard let named = emojis[id] else { return nil }
        return UIImage(named: named)
    }
    
    func attrString(with text: String,
                    scale: CGFloat = 1.2,
                    font: UIFont? = nil) -> NSMutableAttributedString {
        return attrString(with: NSAttributedString(string: text),
                          scale: scale,
                          font: font)
    }
    
    func attrString(with attrString: NSAttributedString,
                    scale: CGFloat = 1.2,
                    font: UIFont? = nil) -> NSMutableAttributedString {
        let resultAttrString = attrString.lp_regex(pattern: regulaPattern, replaceBlock: { (checkingResult) -> NSAttributedString in
            let emotionID = checkingResult.string
            guard let emoji = emoji(by: emotionID) else { return checkingResult }
            let attachment = LPTextAttachment(image: emoji, scale: scale, font: font)
            attachment.tagName = emotionID
            return NSAttributedString(attachment: attachment)
        })
        
        guard let mutableAttrString = resultAttrString else {
            return NSMutableAttributedString(attributedString: attrString)
        }
        return mutableAttrString
    }
}
