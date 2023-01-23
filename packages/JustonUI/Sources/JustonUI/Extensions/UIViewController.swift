//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

public extension UIViewController {
    var jus_isContextMenuViewController: Bool {
        sui_isContextMenuViewController
    }

    var topmostPresentedViewController: UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.topmostPresentedViewController
        } else {
            return self
        }
    }

    func jus_present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
//        let window = view.window
//        window?.layer.speed = 1.3 // this code make broken UIViewPropertyAnimator

        present(viewControllerToPresent, animated: flag, completion: {
//            window?.layer.speed = 1
            completion?()
        })
    }
}
