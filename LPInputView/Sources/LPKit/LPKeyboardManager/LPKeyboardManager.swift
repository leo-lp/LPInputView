//
//  LPKeyboardManager.swift
//  LPKeyboardManager <https://github.com/leo-lp/LPKeyboardManager>
//
//  Created by pengli on 2018/5/17.
//  Copyright © 2018年 pengli. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

import UIKit

public protocol LPKeyboardObserver: class {
    func keyboard(_ keyboard: LPKeyboardManager, willTransition trans: LPKeyboardTransition) -> Void
}

public class LPKeyboardManager {
    public static let shared: LPKeyboardManager = { return LPKeyboardManager() }()
    
    public var keyboardWindow: UIWindow? {
        for window in UIApplication.shared.windows {
            if keyboardView(from: window) != nil {
                return window }
        }
        
        if let window = UIApplication.shared.keyWindow
            , keyboardView(from: window) != nil {
            return window }
        
        var kbWindows: [UIWindow] = []
        for window in UIApplication.shared.windows {
            let windowName = NSStringFromClass(window.classForCoder)
            guard windowName == "UIRemoteKeyboardWindow" else { continue }
            kbWindows.append(window)
        }
        
        return kbWindows.count == 1 ? kbWindows.first : nil
    }
    
    public var keyboardView: UIView? {
        for window in UIApplication.shared.windows {
            if let view = keyboardView(from: window) { return view }
        }
        if let window = UIApplication.shared.keyWindow
            , let view = keyboardView(from: window) { return view }
        return nil
    }
    
    public private(set) var keyboardVisible: Bool = false
//    {
//        guard let window = keyboardWindow
//            , let view = keyboardView else { return false }
//        let rect = window.bounds.intersection(view.frame)
//
//        guard !rect.isNull, !rect.isInfinite else { return false }
//        return rect.width > 0 && rect.height > 0
//    }
    
    public private(set) var keyboardFrame: CGRect = .zero
//    {
//        guard let view = keyboardView else { return .zero }
//        if let window = view.window {
//            return window.convert(view.frame, to: nil)
//        }
//        return view.frame
//    }
    
    public var keyboardSafeAreaInsets: UIEdgeInsets {
        guard #available(iOS 11.0, *)
            , let window = keyboardWindow else { return .zero }
        return window.safeAreaInsets
    }
    
    private var observers = NSHashTable<NSObject>(options: [.weakMemory, .objectPointerPersonality],
                                                  capacity: 0)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(kbFrameWillChangeNotification),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    public func addObserver(_ observer: (NSObject & LPKeyboardObserver)?) {
        guard let observer = observer else { return }
        observers.add(observer)
    }
    
    public func removeObserver(_ observer: (NSObject & LPKeyboardObserver)?) {
        guard let observer = observer else { return }
        observers.remove(observer)
    }
    
    public func convert(_ rect: CGRect, to view: UIView?) -> CGRect {
        guard !rect.isNull, !rect.isInfinite else { return rect }
        guard let mainWindow = (UIApplication.shared.keyWindow
            ?? UIApplication.shared.windows.first) else {
                if let view = view {
                    return view.convert(rect, from: nil)
                }
                return rect
        }
        
        var rect = mainWindow.convert(rect, from: nil)
        guard let view = view else {
            return mainWindow.convert(rect, to: nil)
        }
        if view == mainWindow { return rect }
        
        let toWindowOptional: UIWindow?
        if let window = view as? UIWindow {
            toWindowOptional = window
        } else {
            toWindowOptional = view.window
        }
        guard let toWindow = toWindowOptional else {
            return mainWindow.convert(rect, to: view)
        }
        if mainWindow == toWindow {
            return mainWindow.convert(rect, to: view)
        }
        
        /// 在不同的窗口
        rect = mainWindow.convert(rect, to: mainWindow)
        rect = toWindow.convert(rect, from: mainWindow)
        rect = view.convert(rect, from: toWindow)
        return rect
    }
}

// MARK: - Private Funcs

extension LPKeyboardManager {
    
    private func keyboardView(from window: UIWindow) -> UIView? {
        /// UIRemoteKeyboardWindow
        let windowName = NSStringFromClass(window.classForCoder)
        guard windowName == "UIRemoteKeyboardWindow" else { return nil }
        
        /// Get the view
        /// UIInputSetContainerView
        for view in window.subviews {
            let viewName = NSStringFromClass(view.classForCoder)
            guard viewName == "UIInputSetContainerView" else { continue }
            
            /// UIInputSetHostView
            for subView in view.subviews {
                let subViewName = NSStringFromClass(subView.classForCoder)
                guard subViewName == "UIInputSetHostView" else { continue }
                return subView
            }
        }
        return nil
    }
    
    @objc private func kbFrameWillChangeNotification(_ notif: Notification) {
        guard notif.name == .UIKeyboardWillChangeFrame
            , observers.count > 0
            , let info = notif.userInfo
            , let durationNumber = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
            , let curveNumber = info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            , let animationCurve = UIViewAnimationCurve(rawValue: curveNumber.intValue)
            , let fromFrameValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue
            , let toFrameValue = info[UIKeyboardFrameEndUserInfoKey] as? NSValue
            , let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
            else { return }
        
        let duration = durationNumber.doubleValue
        let animationOption = UIViewAnimationOptions(rawValue: curveNumber.uintValue << 16)
        let fromFrame = fromFrameValue.cgRectValue
        let toFrame = toFrameValue.cgRectValue
        
        /// ignore zero end frame
        if toFrame.width <= 0 && toFrame.height <= 0 { return }
        
        let fromIntersection = window.bounds.intersection(fromFrame)
        let fromVisible = !fromIntersection.isNull && !fromIntersection.isEmpty
        
        let toIntersection = window.bounds.intersection(toFrame)
        let toVisible = !toIntersection.isNull && !toIntersection.isEmpty
        
        var safeAreaInsets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            safeAreaInsets = window.safeAreaInsets
        }
        
        keyboardFrame = toFrame
        keyboardVisible = toVisible
        
        let trans = LPKeyboardTransition(fromVisible: fromVisible,
                                         toVisible: toVisible,
                                         fromFrame: fromFrame,
                                         toFrame: toFrame,
                                         animationDuration: duration,
                                         animationCurve: animationCurve,
                                         animationOption: animationOption,
                                         safeAreaInsets: safeAreaInsets)
        
        let enumerator = observers.objectEnumerator()
        while let value = enumerator.nextObject() {
            guard let observer = value as? LPKeyboardObserver else { continue }
            observer.keyboard(self, willTransition: trans)
        }
    }
}

extension LPKeyboardManager: CustomStringConvertible {
    
    public var description: String {
        let str: String =
        """
        keyboardWindow=\(String(describing: keyboardWindow))
        keyboardView=\(String(describing: keyboardView))
        keyboardVisible=\(keyboardVisible)
        keyboardFrame=\(keyboardFrame)
        keyboardSafeAreaInsets=\(keyboardSafeAreaInsets)
        """
        return str
    }
}
