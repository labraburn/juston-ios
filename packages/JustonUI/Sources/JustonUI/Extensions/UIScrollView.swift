//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

public extension UIScrollView {
    var isScrolledToTop: Bool {
        contentOffset == CGPoint(x: 0, y: -adjustedContentInset.top)
    }

    func scrollToTopIfPossible() {
        sui_scroll(toTopIfPossible: true)
    }
}
