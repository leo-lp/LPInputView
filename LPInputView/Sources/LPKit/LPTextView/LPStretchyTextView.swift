//
//  LPStretchyTextView.swift
//  LPTextView <https://github.com/leo-lp/LPTextView>
//
//  Created by pengli on 2018/5/25.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

open class LPStretchyTextView: LPPlaceholderTextView {
    open private(set) var maxHeight: CGFloat? // 限制输入框的最大高度
    open private(set) var minHeight: CGFloat? // 限制输入框的最小高度
    
    open override var contentSize: CGSize {
        didSet { resize() }
    }
    
    deinit {
        #if DEBUG
        print("LPStretchyTextView:-> release memory.")
        #endif
    }
    
    /// 限制textView可输入的文本行数
    ///
    /// - Parameters:
    ///   - min: 最小行数
    ///   - max: 最大行数
    open func textLines(min: Int?, max: Int?) {
        guard let min = min
            , let max = max else {
            minHeight = nil
            maxHeight = nil
            return
        }
        minHeight = simulateHeight(min)
        maxHeight = simulateHeight(max)
        
        resize()
    }
    
    private func resize() {
        guard let minHeight = minHeight
            , let maxHeight = maxHeight else { return }
        
        let finalHeight = min(max(contentSize.height, minHeight), maxHeight)
        
        if frame.height != finalHeight {
            frame.size.height = finalHeight
            tvDelegate?.textView?(self, heightDidChange: finalHeight)
        }
    }
    
    private func simulateHeight(_ numberOfLines: Int) -> CGFloat {
        /// 如果文本行数为<=0则限制高度为0.0
        guard numberOfLines > 0 else { return 0.0 }
        
        isHidden = true
        
        let saveText = text
        
        var newText = "|W|"
        for _ in 0..<numberOfLines-1 {
            newText += "\n|W|"
        }
        text = newText
        
        let gfm = CGFloat.greatestFiniteMagnitude
        let size = CGSize(width: gfm, height: gfm)
        let height = sizeThatFits(size).height
        
        text = saveText
        isHidden = false
        return height
    }
}
