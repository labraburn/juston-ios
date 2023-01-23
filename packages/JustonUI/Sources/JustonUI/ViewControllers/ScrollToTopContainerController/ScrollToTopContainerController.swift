//
//  Created by Anton Spivak
//

import UIKit

// MARK: - ScrollToTopContainerController

public protocol ScrollToTopContainerController: UIViewController {
    var isScrolledToTop: Bool { get }

    func scrollToTop()
}

// MARK: - UINavigationController + ScrollToTopContainerController

extension UINavigationController: ScrollToTopContainerController {
    public var isScrolledToTop: Bool {
        (viewControllers.last as? ScrollToTopContainerController)?.isScrolledToTop ?? true
    }

    public func scrollToTop() {
        (viewControllers.last as? ScrollToTopContainerController)?.scrollToTop()
    }
}

// MARK: - UITabBarController + ScrollToTopContainerController

extension UITabBarController: ScrollToTopContainerController {
    public var isScrolledToTop: Bool {
        (selectedViewController as? ScrollToTopContainerController)?.isScrolledToTop ?? true
    }

    public func scrollToTop() {
        (selectedViewController as? ScrollToTopContainerController)?.scrollToTop()
    }
}
