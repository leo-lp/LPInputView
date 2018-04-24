//
//  LPEmoticonCell.swift
//  LPInputView
//
//  Created by lipeng on 2017/10/12.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

protocol LPEmoticonCellDelegate: NSObjectProtocol {
    func emoticonInput(_ emoticonKey: String)
    func emoticonDelete()
}

class LPEmoticonCell: UICollectionViewCell {
    private var emoteButtons: [LPButton] = []
    private weak var delegate: LPEmoticonCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.clear
        backgroundView = nil
        backgroundColor = UIColor.clear
        
        let w = UIScreen.main.bounds.width / CGFloat(LPEmoteBarOptions.emoteColumn)
        let h = 156.0 / CGFloat(LPEmoteBarOptions.emoteRow)
        let maxRow = LPEmoteBarOptions.emoteRow - 1
        let maxColumn = LPEmoteBarOptions.emoteColumn - 1
        let indexDelete = maxColumn
        var indexX: Int
        
        for y in 0...maxRow {
            for x in 0...maxColumn {
                indexX = x
                
                let rect = CGRect(x: w * CGFloat(indexX), y: h * CGFloat(y), width: w, height: h)
                let btn = LPButton(frame: rect)
                contentView.addSubview(btn)
                btn.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
                
                emoteButtons.append(btn)
                
                if y == maxRow && indexX == indexDelete {
                    btn.bind(tag: nil, img: "btn_room_face_delect")
                }
            }
        }
    }

    @objc func buttonClicked(_ sender: LPButton) {
        if let emoticonKey = sender.tagName {
            delegate?.emoticonInput(emoticonKey)
        } else {
            delegate?.emoticonDelete()
        }
    }
    
    func bindData(emotes: [(String, String)], indexPath: IndexPath, delegate: LPEmoticonCellDelegate?) {
        self.delegate = delegate
        
        let emoteNum = LPEmoteBarOptions.emoteNum
        for i in 0..<emoteNum where i < emoteButtons.count {
            let btn = emoteButtons[i]
            let index = indexPath.row * emoteNum + i
            if index < emotes.count {
                let emote = emotes[index]
                let imgName = LPEmotion.shared.emojiPath + emote.1
                btn.bind(tag: emote.0, img: imgName)
                btn.isHidden = false
            } else {
                btn.isHidden = true
            }
        }
    }
}

extension LPEmoticonCell {
    
    class LPButton: UIControl {
        private(set) var imageView: UIImageView = {
            return UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        }()
        private(set) var tagName: String?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
        
        private func commonInit() {
            imageView.isUserInteractionEnabled = false
            imageView.contentMode = .scaleAspectFit
            addSubview(imageView)
        }
        
        func bind(tag: String?, img: String) {
            tagName = tag
            imageView.image = UIImage(named: img)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            imageView.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        }
    }
}
