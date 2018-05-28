//
//  LPPlaceholderTextView.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

open class LPPlaceholderTextView: UITextView {
    open weak var tvDelegate: LPTextViewDelegate?
    
    open var placeholder: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    
    open private(set) var textIsEmpty: Bool = true {
        didSet {
            if textIsEmpty != oldValue { setNeedsDisplay() }
        }
    }
    
    deinit {
        #if DEBUG
        print("LPPlaceholderTextView:-> release memory.")
        #endif
    }

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor.clear
        textStorage.delegate = self
    }
    
    open override func draw(_ rect: CGRect) {
        guard textIsEmpty
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
            , let font = font {
            attr.addAttribute(.font, value: font, range: allRange)
        }
        
        if attr.attribute(.foregroundColor, at: 0, effectiveRange: nil) == nil
            , let color = textColor {
            attr.addAttribute(.foregroundColor, value: color, range: allRange)
        }
        
        attr.draw(in: targetRect)
    }
}

// MARK: - NSTextStorageDelegate

extension LPPlaceholderTextView: NSTextStorageDelegate {
    
    public func textStorage(_ textStorage: NSTextStorage,
                            didProcessEditing editedMask: NSTextStorageEditActions,
                            range editedRange: NSRange,
                            changeInLength delta: Int) {
        textIsEmpty = textStorage.length == 0
        tvDelegate?.textView?(self,
                              didProcessEditing: editedRange,
                              changeInLength: delta)
    }
}
