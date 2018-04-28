//
//  LPInputModel.swift
//  LPInputView
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

public struct LPInputToolBarItemType: OptionSet, Hashable {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none    = LPInputToolBarItemType.text
    
    /// 录音切换按钮
    //public static let voice   = LPInputToolBarItemType(rawValue: 1 << 1)
    
    /// @好友
    public static let at      = LPInputToolBarItemType(rawValue: 1 << 2)
    
    /// 文本输入框
    public static let text    = LPInputToolBarItemType(rawValue: 1 << 3)
    
    /// 表情贴图
    public static let emotion = LPInputToolBarItemType(rawValue: 1 << 4)
    
    /// 更多菜单
    public static let more    = LPInputToolBarItemType(rawValue: 1 << 5)
}

public enum LPInputSeparatorLocation {
    case top
    case bottom
}


// MARK: -
// MARK: - LPAtUser

public class LPAtUser: NSObject, NSCoding, NSCopying {
    public static var AtCharacter: String = "@"

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
        return "{\"id\": \"\(id)\", \"name\": \"\(name)\"}"
    }
}


public struct LPParseResult: CustomStringConvertible {
    public var attrString: NSMutableAttributedString
    public var emotionCount: Int

    public var user: [(placeholder: String, user: LPAtUser)]?

    public var text: String { return attrString.string }

    public var description: String {
        let str: String =
        """
        文本：\(text)
        表情个数：\(emotionCount)
        @用户个数：\(user?.count ?? 0)
        @用户：\(user?.description ?? "")
        """
        return str
    }
}
