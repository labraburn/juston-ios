//
//  Created by Anton Spivak
//

import UIKit

public class KeyboardLayoutConstraint: NSLayoutConstraint {
    // MARK: Lifecycle

    public override init() {
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowNotification(_:)),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrameNotification(_:)),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideNotification(_:)),
            name: UIWindow.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public

    public struct WeakView {
        // MARK: Lifecycle

        public init(_ view: UIView) {
            self.view = view
        }

        // MARK: Public

        public weak var view: UIView?
    }

    public enum BottomAnchor {
        case none
        case screen
        case view(view: WeakView)
    }

    public enum ResponderChecker {
        case none
        case view(view: WeakView)
    }

    public var keyboardOffset = CGFloat(16)

    public var bottomAnchor: BottomAnchor = .none {
        didSet {
            guard propagateConstantIfNeeded()
            else {
                return
            }

            animateChanges(
                duration: 0.42,
                curve: .easeInOut
            )
        }
    }

    public var responderChecker: ResponderChecker = .none {
        didSet {
            guard propagateConstantIfNeeded()
            else {
                return
            }

            animateChanges(
                duration: 0.42,
                curve: .easeInOut
            )
        }
    }

    public override var constant: CGFloat {
        get { super.constant }
        set {
            originalConstant = newValue
            propagateConstantIfNeeded()
        }
    }

    // MARK: Private

    private var originalConstant: CGFloat = 0
    private var keyboardHeight: CGFloat = 0
    private var animator: UIViewPropertyAnimator?

    @discardableResult
    private func propagateConstantIfNeeded() -> Bool {
        let canUpdateConstant: Bool
        switch responderChecker {
        case .none:
            canUpdateConstant = true
        case let .view(view):
            if let view = view.view, view.isFirstResponder {
                canUpdateConstant = true
            } else {
                canUpdateConstant = false
            }
        }

        let constant: CGFloat
        if keyboardHeight > 0, canUpdateConstant {
            switch bottomAnchor {
            case .none:
                constant = originalConstant
            case .screen:
                constant = keyboardHeight + keyboardOffset
            case let .view(wview):
                if let view = wview.view,
                   let superview = view.superview,
                   let window = view.window
                {
                    let frame = superview.convert(view.frame, to: nil)
                    let target = keyboardHeight - (window.bounds.height - frame.minY) +
                        keyboardOffset
                    constant = target > 0 ? target : originalConstant
                } else {
                    constant = keyboardHeight + keyboardOffset
                }
            }
        } else {
            constant = originalConstant
        }

        guard super.constant != constant
        else {
            return false
        }

        super.constant = constant
        return true
    }

    private func animateChanges(
        notification: Notification
    ) {
        let duration = notification
            .userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let curve = notification
            .userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0

        animateChanges(
            duration: TimeInterval(duration > 0 ? duration : 0.24) * 1.5,
            curve: UIView.AnimationCurve(rawValue: curve) ?? .easeInOut
        )
    }

    private func animateChanges(
        duration: TimeInterval,
        curve: UIView.AnimationCurve
    ) {
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .current)

        animator = nil
        animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        )

        animator?.addAnimations({
            (self.firstItem as? UIView)?.superview?.layoutIfNeeded()
            (self.secondItem as? UIView)?.superview?.layoutIfNeeded()
        })

        animator?.startAnimation()
    }

    // MARK: Observing

    @objc
    private func keyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }

        let frame = frameValue.cgRectValue
        keyboardHeight = frame.size.height

        guard propagateConstantIfNeeded()
        else {
            return
        }

        animateChanges(notification: notification)
    }

    @objc
    private func keyboardDidChangeFrameNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }

        let frame = frameValue.cgRectValue
        keyboardHeight = frame.size.height

        guard propagateConstantIfNeeded()
        else {
            return
        }

        animateChanges(notification: notification)
    }

    @objc
    private func keyboardWillHideNotification(_ notification: Notification) {
        keyboardHeight = 0
        propagateConstantIfNeeded()
        animateChanges(notification: notification)
    }
}
