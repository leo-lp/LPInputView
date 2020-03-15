//
//  LPCustomInputViewCell.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/17.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit
import LPInputView

class LPCustomInputViewCell: UITableViewCell {
    @IBOutlet weak var textView: LPAtTextView!
        
    deinit {
        print("LPCustomInputViewCell: -> release memory.")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.font = UIFont.systemFont(ofSize: 15.0)
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.clear
        textView.returnKeyType = .send
        textView.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4

        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.brown]
        textView.placeholder = NSAttributedString(string: "说点什么...", attributes: attributes)
    }
}
