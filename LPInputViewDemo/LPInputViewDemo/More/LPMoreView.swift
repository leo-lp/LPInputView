//
//  LPMoreView.swift
//  LPInputViewDemo
//
//  Created by pengli on 2018/4/18.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

class LPMoreView: UIView {
    deinit {
        print("LPMoreView: -> release memory.")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(target: Any?, action: Selector) {
        super.init(frame: .zero)
        setup(target: target, action: action)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 216.0)
    }
}

extension LPMoreView {
    private struct LPModel {
        let img: UIImage
        let title: String
    }
    
    private func setup(target: Any?, action: Selector) {
        backgroundColor = UIColor.white
        let itemWidth: CGFloat = UIScreen.main.bounds.width / 3
        let btnWidth: CGFloat = 75
        let models: [LPModel] = [LPModel(img: #imageLiteral(resourceName: "bk_media_picture_normal"), title: "相册"),
                                 LPModel(img: #imageLiteral(resourceName: "bk_media_shoot_normal"), title: "拍摄"),
                                 LPModel(img: #imageLiteral(resourceName: "bk_media_position_normal"), title: "位置")]
        for (idx, model) in models.enumerated() {
            let rect = CGRect(x: CGFloat(idx) * itemWidth + (itemWidth - btnWidth) / 2,
                              y: 0,
                              width: btnWidth,
                              height: 85)
            let btn = UIButton(frame: rect)
            btn.tag = idx
            btn.setImage(model.img, for: .normal)
            btn.setTitle(model.title, for: .normal)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.titleEdgeInsets = UIEdgeInsets(top: 76, left: -btnWidth, bottom: 0, right: 0)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.addTarget(target, action: action, for: .touchUpInside)
            
            addSubview(btn)
        }
    }

}
