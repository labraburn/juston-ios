//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

class C42NavigationController: NavigationController {
    // MARK: Lifecycle

    init(rootViewController: C42ViewController) {
        super.init(nibName: nil, bundle: nil)
        pushViewController(rootViewController, animated: false)
        modalPresentationStyle = .pageSheet
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override var isModalInPresentation: Bool {
        get {
            topViewController?.isModalInPresentation ?? super.isModalInPresentation
        }
        set {
            super.isModalInPresentation = newValue
        }
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        updateWithCurrentViewController(animated: animated)
    }

    override func popToViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {
        let result = super.popToViewController(viewController, animated: animated)
        updateWithCurrentViewController(animated: animated)
        return result
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let result = super.popToRootViewController(animated: animated)
        updateWithCurrentViewController(animated: animated)
        return result
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let result = super.popViewController(animated: animated)
        updateWithCurrentViewController(animated: animated)
        return result
    }

    func next(_ viewController: C42ViewController) {
        pushViewController(viewController, animated: true)
    }

    func finish() {
        hide(animated: true)
    }

    // MARK: Private

    private func updateWithCurrentViewController(animated: Bool) {
        let topViewController = topViewController as? C42ViewController
        isModalInPresentation = topViewController?.isModalInPresentation ?? false
        setNavigationBarHidden(
            topViewController?.isNavigationBarHidden ?? false,
            animated: animated
        )
    }
}
