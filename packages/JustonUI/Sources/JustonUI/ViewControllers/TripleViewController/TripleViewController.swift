//
//  Created by Anton Spivak
//

import UIKit

// MARK: - TripleViewControllerDelegate

public protocol TripleViewControllerDelegate: AnyObject {
    func tripleViewController(
        _ viewController: TripleViewController,
        didChangeOffset offset: CGPoint
    )

    func tripleViewController(
        _ viewController: TripleViewController,
        didChangePresentation presentation: TriplePresentation
    )
}

// MARK: - TripleMiddleViewController

public protocol TripleMiddleViewController: UIViewController {
    func compactHeight(
        for positioning: TripleCompactPositioning
    ) -> CGFloat
}

// MARK: - TripleViewController

open class TripleViewController: UIViewController {
    // MARK: Lifecycle

    public init(
        _ viewControllers: (UIViewController, TripleMiddleViewController, UIViewController)
    ) {
        self.viewControlles = viewControllers

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    @available(*, unavailable)
    required public init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Open

    open override var childForStatusBarStyle: UIViewController? { selectedViewController }
    open override var childForHomeIndicatorAutoHidden: UIViewController? { selectedViewController }
    open override var childForStatusBarHidden: UIViewController? { selectedViewController }

    open override var childViewControllerForPointerLock: UIViewController? {
        selectedViewController
    }

    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        selectedViewController
    }

    open override func loadView() {
        addChild(viewControlles.0)
        addChild(viewControlles.1)
        addChild(viewControlles.2)

        let tripleView = TripleView(
            views: (
                viewControlles.0.view,
                viewControlles.1.view,
                viewControlles.2.view
            )
        )

        tripleView.delegate = self
        view = tripleView

        viewControlles.0.didMove(toParent: self)
        viewControlles.1.didMove(toParent: self)
        viewControlles.2.didMove(toParent: self)
    }

    open func update(
        presentation: TriplePresentation,
        animated: Bool
    ) {
        tripleView.update(
            presentation: presentation,
            animated: animated
        )
    }

    // MARK: Public

    public let viewControlles: (UIViewController, TripleMiddleViewController, UIViewController)

    public weak var delegate: TripleViewControllerDelegate?

    public var presentation: TriplePresentation {
        tripleView.presentation
    }

    public var isGesturesEnabled: Bool {
        get { tripleView.panGestureRecognizer.isEnabled }
        set { tripleView.panGestureRecognizer.isEnabled = newValue }
    }

    // MARK: Private

    private let feedbackGenerator = UIImpactFeedbackGenerator(
        style: .medium
    )

    private var tripleView: TripleView {
        view as! TripleView
    }

    private var selectedViewController: UIViewController {
        switch presentation {
        case .top:
            return viewControlles.0
        case .middle:
            return viewControlles.1
        case .bottom:
            return viewControlles.2
        }
    }

    private func updateAppearance(
        animated: Bool,
        duration: TimeInterval = 0.21
    ) {
        let animations = {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            if #available(iOS 14.0, *) {
                self.setNeedsUpdateOfPrefersPointerLocked()
            }
        }

        if animated {
            UIView.animate(withDuration: duration, animations: animations)
        } else {
            animations()
        }
    }
}

// MARK: TripleViewDelegate

extension TripleViewController: TripleViewDelegate {
    func tripleView(
        _ view: TripleView,
        didChangePresentation presentation: TriplePresentation
    ) {
        feedbackGenerator.impactOccurred()
        updateAppearance(animated: true, duration: 0.16)
        delegate?.tripleViewController(
            self,
            didChangePresentation: presentation
        )
    }

    func tripleView(
        _ view: TripleView,
        didChangeBounds bounds: CGRect
    ) {
        delegate?.tripleViewController(
            self,
            didChangeOffset: bounds.origin
        )
    }

    func tripleView(
        _view: TripleView,
        heightForCompactMiddleViewWithPositioning positioning: TripleCompactPositioning
    ) -> CGFloat {
        viewControlles.1.compactHeight(for: positioning)
    }
}
