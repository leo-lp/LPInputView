//
//  LPInputBar.swift
//  LPInputView <https://github.com/leo-lp/LPInputView>
//
//  Created by pengli on 2018/4/23.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public class LPInputBar: UIView, LPTextViewDelegate {
    private(set) weak var dataSource: LPInputBarDataSource?
    weak var delegate: LPInputBarDelegate?
    
    public lazy var contentInset: UIEdgeInsets = {
        return dataSource?.edgeInsets(in: self) ?? UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }()
    public lazy var interitemSpacing: CGFloat = {
        return dataSource?.interitemSpacing(in: self) ?? 10
    }()
    private lazy var topSeparator: UIView? = createSeparator(for: .top)
    private lazy var bottomSeparator: UIView? = createSeparator(for: .top)
    private lazy var items: [LPInputBarItemType: UIView] = [:]
    private var itemTypes: [LPInputBarItemType]
    
    deinit {
        #if DEBUG
        print("LPInputBar: -> release memory.")
        #endif
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init?(frame: CGRect, dataSource: LPInputBarDataSource?) {
        guard let dataSource = dataSource else {
            assert(false, "dataSource不能为空")
            return nil
        }
        self.dataSource = dataSource
        self.itemTypes = dataSource.inputBarItemTypes
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var viewHeight: CGFloat = 0.0
        if let textView = textView, textView.superview is LPInputBar {
            textView.frame.size.width = size.width
            viewHeight = textView.frame.height
        } else if let item = items.first {
            viewHeight = item.value.frame.height
        }
        viewHeight = viewHeight + contentInset.top + contentInset.bottom
        return CGSize(width: size.width, height: viewHeight)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let textView = textView, !textView.isHidden {
            var left = layoutLeftItems()
            var right = layoutRightItems()
            left = left > 0.0 ? left + interitemSpacing : left + contentInset.left
            right = right > 0.0 ? right - interitemSpacing : right - contentInset.right
            textView.frame.origin.x = left
            textView.frame.size.width = right - left
            textView.center.y = frame.height / 2.0
        }
        topSeparator?.frame = CGRect(x: 0, y: 0, width: frame.width, height: 0.5)
        bottomSeparator?.frame = CGRect(x: 0, y: frame.height - 0.5, width: frame.width, height: 0.5)
    }
    
    public func item(with type: LPInputBarItemType) -> UIView? {
        if let item = items[type] { return item }
        guard let dataSource = dataSource else { assert(false); return nil }
        let item: UIView
        switch type {
        case .text:
            let textView = LPAtTextView(frame: .zero)
            textView.font = UIFont.systemFont(ofSize: 14.0)
            textView.textColor = UIColor.black
            textView.backgroundColor = UIColor.clear
            textView.returnKeyType = .send
            dataSource.inputBar(self, configure: textView, for: type)
            textView.tag = type.rawValue
            item = textView
        case .emotion, .more, .at:
            let button = UIButton(type: .custom)
            dataSource.inputBar(self, configure: button, for: type)
            button.tag = type.rawValue
            button.sizeToFit()
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            item = button
        case .custom:
            guard let view = dataSource.inputBar(self, customItemFor: type) else { return nil }
            view.sizeToFit()
            view.tag = type.rawValue
            item = view
        }
        items[type] = item
        addSubview(item)
        return item
    }
    
    public var textView: LPAtTextView? {
        guard itemTypes.contains(.text) else { return dataSource?.customTextView(in: self) }
        guard let textView = item(with: .text) as? LPAtTextView else { return nil }
        textView.lpDelegate = self
        textView.isAtEnabled = dataSource?.isAtEnabled(in: self, textView: textView) ?? false
        return textView
    }
    
    public var isShowKeyboard: Bool {
        get { return textView?.isFirstResponder ?? false }
        set {
            if newValue {
                textView?.becomeFirstResponder()
            } else {
                textView?.resignFirstResponder()
            }
        }
    }
    
    // MARK: - LPTextViewDelegate
    public func textView(_ textView: UITextView, heightDidChange newHeight: CGFloat) {
        guard let delegate = delegate else { return }
        let height = newHeight + contentInset.top + contentInset.bottom
        guard frame.height != height else { return }
        animate({
            self.frame.size.height = height
        }, completion: nil)
        delegate.inputBar(self, didChange: height)
    }
    
    public func textView(_ textView: UITextView, inputAtCharacter character: String) {
        delegate?.inputBar(self, inputAtCharacter: character)
    }
    
    public func textView(_ textView: UITextView, didProcessEditing editedRange: NSRange, changeInLength delta: Int) {
        delegate?.inputBar(self, textView: textView, didProcessEditing: editedRange, changeInLength: delta)
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.inputBar(self, textViewShouldBeginEditing: textView) ?? true
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate?.inputBar(self, textView: textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
    // MARK: - Private
    
    private func createSeparator(for loca: LPInputSeparatorLocation) -> UIView? {
        guard let color = dataSource?.inputBar(self, separatorColorFor: .top) else { return nil }
        let separator = UIView()
        separator.backgroundColor = color
        addSubview(separator)
        return separator
    }
    
    private func layoutLeftItems() -> CGFloat {
        var left: CGFloat = 0.0
        for (idx, type) in itemTypes.enumerated() {
            guard let item = item(with: type) else { continue }
            if item is LPAtTextView {
                return left
            } else if !item.isHidden {
                if idx == 0 {
                    item.frame.origin.x = contentInset.left
                } else {
                    item.frame.origin.x = left + interitemSpacing
                }
                item.center.y = frame.height / 2.0
                left = item.frame.maxX
            }
        }
        return left
    }
    
    private func layoutRightItems() -> CGFloat {
        var right: CGFloat = 0.0
        let totalCount: Int = itemTypes.count - 1
        for (idx, type) in itemTypes.enumerated().reversed() {
            guard let item = item(with: type) else { continue }
            if item is LPAtTextView {
                return right
            } else if !item.isHidden {
                if idx == totalCount {
                    item.frame.origin.x = frame.width - contentInset.right - item.frame.width
                } else {
                    item.frame.origin.x = right - interitemSpacing - item.frame.width
                }
                item.center.y = frame.height / 2.0
                right = item.frame.origin.x
            }
        }
        return right
    }
    
    @objc private func buttonClicked(_ sender: UIButton) {
        delegate?.inputBar(self, clickedAt: sender, for: LPInputBarItemType(rawValue: sender.tag))
    }
    
    private func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: UIView.AnimationOptions(rawValue: 7),
                       animations: animations,
                       completion: completion)
    }
}
