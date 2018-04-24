//
//  LPEmoticonView.swift
//  LPInputView
//
//  Created by lipeng on 2017/10/12.
//  Copyright © 2018年 pengli. All rights reserved.
//

import UIKit

struct LPEmoteBarOptions {
    static let emoteBarHeight: CGFloat = 216.0  // 表情bar的高度
    static let emoteColumn: Int = 7 // 每页表情列数
    static let emoteRow: Int = 3    // 每页表情行数 fileprivate
    static var emoteNum: Int {
        return LPEmoteBarOptions.emoteColumn * LPEmoteBarOptions.emoteRow - 1 // 每页表情总个数
    }
}

protocol LPEmoticonViewDelegate: class {
    func inputEmoticon(id: String, img: UIImage)
    func inputEmoticonDelete()
    func inputEmoticonSend()
}

class LPEmoticonView: UIView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var emotes: [(String, String)] = []
    
    weak var delegate: LPEmoticonViewDelegate?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("release memory.")
    }
    
    class func instance(delegate: LPEmoticonViewDelegate?) -> LPEmoticonView? {
        guard let views = Bundle.main.loadNibNamed("LPEmoticonView", owner: self, options: nil) else { return nil }
        let emoteView = views.first as? LPEmoticonView
        emoteView?.delegate = delegate
        return emoteView
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: LPEmoteBarOptions.emoteBarHeight)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 156.0)
        flowLayout.sectionInset = .zero
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
        collectionView.backgroundView = nil
        collectionView.bounces = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "LPEmoticonCell", bundle: nil), forCellWithReuseIdentifier: "LPEmoticonCell")
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        } else {
            // Fallback on earlier versions
        }
        
        sendButton.setTitle("发送", for: .normal)
        
        func renewConifg() {
            let count = emotes.count
            let emoteNum = LPEmoteBarOptions.emoteNum
            pageControl.numberOfPages = count % emoteNum == 0 ? count / emoteNum : count / emoteNum + 1
            pageControl.currentPage = 0
            collectionView.reloadData()
        }
        
        indicator.startAnimating()
        DispatchQueue.global().async {
            let emotes = LPEmotion.shared.emojis.sorted { $0.0 < $1.0 }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.indicator.stopAnimating()
                self.emotes = emotes
                renewConifg()
            }
        }
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let count = emotes.count
        let emoteNum = LPEmoteBarOptions.emoteNum
        let pages = count % emoteNum == 0 ? count / emoteNum : count / emoteNum + 1
        if sender.currentPage < pages {
            let indexPath = IndexPath(item: sender.currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath,
                                        at: UICollectionViewScrollPosition(rawValue: 0),
                                        animated: true)
        }
    }
    
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        delegate?.inputEmoticonSend()
    }
}

extension LPEmoticonView: UICollectionViewDelegate, UICollectionViewDataSource, LPEmoticonCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = emotes.count
        let emoteNum = LPEmoteBarOptions.emoteNum
        return count % emoteNum == 0 ? count / emoteNum : count / emoteNum + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LPEmoticonCell", for: indexPath) as! LPEmoticonCell
        cell.bindData(emotes: emotes, indexPath: indexPath, delegate: self)
        return cell
    }
    
    /// 当滚动试图停止滚动时调用
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = Int(scrollView.contentOffset.x)
        let width = Int(frame.width)
        pageControl.currentPage = (x % width == 0) ? x / width : x / width + 1
    }

    // MARK: - LPEmoticonCellDelegate
    
    func emoticonInput(_ emoticonKey: String) {
        if let emoji = LPEmotion.shared.emoji(by: emoticonKey) {
            delegate?.inputEmoticon(id: emoticonKey, img: emoji)
        }
    }
    
    func emoticonDelete() {
        delegate?.inputEmoticonDelete()
    }
}
