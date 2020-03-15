//
//  LPCustomInputToolBar.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/16.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPCustomInputToolBar: UIView {
    @IBOutlet weak var emotionButton: UIButton!
    @IBOutlet weak var atButton: UIButton!
    @IBOutlet weak var loationButton: UIButton!
    
    class func instance() -> LPCustomInputToolBar? {
        guard let views = Bundle.main.loadNibNamed("LPCustomInputToolBar", owner: self, options: nil) else { return nil }
        return views.first as? LPCustomInputToolBar
    }
    
    deinit {
        print("LPCustomInputToolBar: -> release memory.")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: size.height)
    }
}
