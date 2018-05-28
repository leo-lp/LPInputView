//
//  LPModels.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

// MARK: -
// MARK: - LPAtUser

public class LPAtUser: NSObject, NSCoding, NSCopying {
    public static let AtCharacter: String = "@"
    
    public let id: Int
    public let name: String
    public let nameColor: UIColor
    public var atName: String { return "\(LPAtUser.AtCharacter)\(name)" }
    
    public init(id: Int, name: String, nameColor: UIColor = #colorLiteral(red: 0, green: 0.8470588235, blue: 0.7882352941, alpha: 1)) {
        self.id = id
        self.name = name
        self.nameColor = nameColor
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(nameColor, forKey: "nameColor")
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        let nameColor = aDecoder.decodeObject(forKey: "nameColor") as? UIColor ?? #colorLiteral(red: 0, green: 0.8470588235, blue: 0.7882352941, alpha: 1)
        self.init(id: id, name: name, nameColor: nameColor)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return LPAtUser(id: id, name: name, nameColor: nameColor)
    }
    
    public override var description: String {
        let str: String =
        """
            用户ID：\(id)
            用户name：\(name)
        """
        return str
    }
    
    deinit {
        #if DEBUG
        print("LPAtUser:-> release memory.")
        #endif
    }
}

// MARK: -
// MARK: - LPEmotion

public class LPEmotion: NSObject, NSCoding, NSCopying {
    public var placeholder: String? // 占位符
    public var imageScale: CGFloat
    public var alignment: LPTextAttachment.LPAlignment
    public var font: UIFont?
    public var image: UIImage?
    
    public init(placeholder: String?,
                imageScale: CGFloat,
                alignment: LPTextAttachment.LPAlignment,
                font: UIFont?,
                image: UIImage?) {
        self.placeholder = placeholder
        self.imageScale = imageScale
        self.alignment = alignment
        self.font = font
        self.image = image
    }
    
    public init(with attachment: LPTextAttachment) {
        self.placeholder = attachment.tagName
        self.imageScale = attachment.imageScale
        self.alignment = attachment.alignment
        self.font = attachment.font
        self.image = attachment.image
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(placeholder, forKey: "placeholder")
        aCoder.encode(imageScale, forKey: "imageScale")
        aCoder.encode(alignment.rawValue, forKey: "alignment")
        aCoder.encode(font?.pointSize, forKey: "fontSize")
        
        if let image = image, let data = UIImagePNGRepresentation(image) {
            aCoder.encode(data, forKey: "imageData")
        }
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let placeholder = aDecoder.decodeObject(forKey: "placeholder") as? String ?? ""
        let imageScale = aDecoder.decodeObject(forKey: "imageScale") as? CGFloat ?? 1
        let alignmentValue = aDecoder.decodeInteger(forKey: "alignment")
        let alignment = LPTextAttachment.LPAlignment(rawValue: alignmentValue) ?? .center
        
        var font: UIFont? = nil
        if let fontSize = aDecoder.decodeObject(forKey: "fontSize") as? CGFloat {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        
        var image: UIImage? = nil
        if let imageData = aDecoder.decodeObject(forKey: "imageData") as? Data {
            image = UIImage(data: imageData)
        }
        self.init(placeholder: placeholder,
                  imageScale: imageScale,
                  alignment: alignment,
                  font: font,
                  image: image)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return LPEmotion(placeholder: placeholder,
                         imageScale: imageScale,
                         alignment: alignment,
                         font: font,
                         image: image)
    }
    
    public override var description: String {
        let str: String =
        """
            表情占位符placeholder：\(String(describing: placeholder))
            表情缩放imageScale：\(imageScale)
            表情对齐方式alignment：\(alignment.rawValue)
            字体font：\(String(describing: font))
            表情图片image：\(String(describing: image))
        """
        return str
    }
    
    deinit {
        #if DEBUG
        print("LPEmotion:-> release memory.")
        #endif
    }
}

// MARK: -
// MARK: - LPParseResult

public struct LPParseResult: CustomStringConvertible {
    public var attrString: NSMutableAttributedString
    public var text: String { return attrString.string }
    
    public var emotionCount: Int
    public var emotions: [String: LPEmotion]?
    
    public var users: [(placeholder: String, user: LPAtUser)]?
    
    public var description: String {
        let str: String =
        """
        文本：\(text)
        表情个数：\(emotionCount)
        表情：
            \(emotions?.description ?? "")
        @用户个数：\(users?.count ?? 0)
        @用户：
            \(users?.description ?? "")
        """
        return str
    }
}
