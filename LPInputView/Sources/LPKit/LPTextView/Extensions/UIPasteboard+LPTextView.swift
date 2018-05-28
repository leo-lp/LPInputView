//
//  UIPasteboard+LPTextView.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit.UIPasteboard

public extension UIPasteboard {
    static let LPPasteboardAttrStr: String = "com.lp.LPTextView.pasteboard.attrStr"
    
    /// 为UIPasteboard扩展粘贴富文本功能
    /// 注：富文本主要包含LPTextAttachment和@用户
    var lp_attributedString: NSAttributedString? {
        get {
            for item in items {
                if let data = item[UIPasteboard.LPPasteboardAttrStr] as? Data
                    , let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any]
                    , let attrString = lp_attributedString(with: dict) {
                    return attrString
                }
            }
            
            guard let string = string else { return nil }
            return NSAttributedString(string: string)
        }
        
        set {
            guard let newValue = newValue else { return }
            let result = newValue.lp_parseEmotion()
            
            string = result.attrString.string
            
            var dict: [String: Any] = ["LPAttrString": result.attrString]
            if let emotions = result.emotions, emotions.count > 0 {
                dict["LPEmotions"] = emotions
            }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: dict)
            addItems([[UIPasteboard.LPPasteboardAttrStr: data]])
        }
    }
    
    private func lp_attributedString(with dict: [String: Any]) -> NSAttributedString? {
        guard let mutableAttrString = dict["LPAttrString"] as? NSMutableAttributedString else {
            return nil
        }
        
        guard let emotions = dict["LPEmotions"] as? [String: LPEmotion], emotions.count > 0 else {
            return mutableAttrString
        }
        
        let key = NSAttributedStringKey.LPEmotionID
        let range = NSRange(location: 0, length: mutableAttrString.length)
        let options = NSAttributedString.EnumerationOptions.reverse
        mutableAttrString.enumerateAttribute(key, in: range, options: options) { (obj, range, stop) in
            if let emotionID = obj as? String
                , let emotion = emotions[emotionID]
                , let image = emotion.image {
                let attachment = LPTextAttachment(image: image,
                                                  scale: emotion.imageScale,
                                                  alignment: emotion.alignment,
                                                  tag: emotion.placeholder,
                                                  font: emotion.font)
                mutableAttrString.removeAttribute(key, range: range)
                let attrString = NSAttributedString(attachment: attachment)
                mutableAttrString.replaceCharacters(in: range, with: attrString)
            }
        }
        return mutableAttrString
    }
}
