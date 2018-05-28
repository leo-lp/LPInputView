//
//  LPTextAttachment.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public extension LPTextAttachment {
    /// image垂直对齐方式
    ///
    /// - top: 顶部对齐
    /// - center: 居中对齐
    /// - bottom: 底部对齐
    public enum LPAlignment: Int {
        case top = 0
        case center = 1
        case bottom = 2
    }
}

public class LPTextAttachment: NSTextAttachment {
    public var tagName: String? // 标记
    public var imageScale: CGFloat = 1.0
    public var alignment: LPAlignment = .center
    public var font: UIFont?
    
    private var baseLineHeight: CGFloat = 0.0
    
    public convenience init(image: UIImage,
                            scale: CGFloat = 1.0,
                            alignment: LPAlignment = .center,
                            tag: String? = nil,
                            font: UIFont? = nil) {
        self.init()
        self.image = image
        self.imageScale = scale
        self.alignment = alignment
        self.tagName = tag
        self.font = font
    }
    
    // 重写以返回附件的大小
    public override func attachmentBounds(for textContainer: NSTextContainer?,
                                          proposedLineFragment lineFrag: CGRect,
                                          glyphPosition position: CGPoint,
                                          characterIndex charIndex: Int) -> CGRect {
        guard let img = image else {
            return super.attachmentBounds(for: textContainer,
                                          proposedLineFragment: lineFrag,
                                          glyphPosition: position,
                                          characterIndex: charIndex)
        }
        
        var y: CGFloat = 0.0
        if let textContainer = textContainer
            , let layoutManager = textContainer.layoutManager
            , let textStorage = layoutManager.textStorage
            , let font = textStorage.attribute(.font, at: charIndex, effectiveRange: nil) as? UIFont {
            baseLineHeight = font.lineHeight
            y = font.descender
        } else if let font = font {
            baseLineHeight = font.lineHeight
            y = font.descender
        } else if baseLineHeight == 0.0 {
            baseLineHeight = lineFrag.height
        }
        
        let height = baseLineHeight * imageScale
        let width = height * img.size.width / img.size.height
        
        switch alignment {
        case .top: y -= (height - baseLineHeight)
        case .center: y -= (height - baseLineHeight) / 2
        case .bottom: y = 0.0
        }
        return CGRect(x: 0, y: y, width: width, height: height)
    }
    
//    deinit {
//        print("LPTextAttachment: -> release memory.")
//    }
}
