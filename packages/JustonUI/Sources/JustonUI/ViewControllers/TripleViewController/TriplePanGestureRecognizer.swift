//
//  Created by Anton Spivak
//

import UIKit

internal final class TriplePanGestureRecognizer: UIPanGestureRecognizer {
    override func canBePrevented(
        by preventingGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let panGestureRecognizer = preventingGestureRecognizer as? UIPanGestureRecognizer,
           let scrollView = preventingGestureRecognizer.view as? UIScrollView
        {
            let velocity = panGestureRecognizer.velocity(in: scrollView)
            if velocity.y > 0 {
                if scrollView.refreshControl == nil {
                    return scrollView.contentOffset.y + scrollView.adjustedContentInset.top > 0
                } else {
                    return true
                }
            } else if velocity.y < 0 {
                return scrollView.contentOffset.y < scrollView.contentSize.height - scrollView
                    .bounds.height
            } else {
                return false
            }
        }
        return false
    }

    // Inspired via
    // https://github.com/jenox/UIKit-Playground/tree/master/02-Gestures-In-Fluid-Interfaces/
    func project(
        _ velocity: CGPoint,
        onto position: CGPoint
    ) -> CGPoint {
        // UIScrollView.DecelerationRate
        let decelerationRate = 0.9966
        let factor = -1 / (1000 * log(decelerationRate))
        return CGPoint(
            x: position.x + factor * velocity.x,
            y: position.y + factor * velocity.y
        )
    }
}
