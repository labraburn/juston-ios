//
//  Created by Anton Spivak
//

import Foundation
import UIKit

struct AlertViewControllerImage {
    // MARK: Lifecycle

    private init(
        image: UIImage?,
        tintColor: UIColor?
    ) {
        self.image = image
        self.tintColor = tintColor
    }

    // MARK: Internal

    let image: UIImage?
    let tintColor: UIColor?

    static func image(_ image: UIImage?, tintColor: UIColor? = nil) -> AlertViewControllerImage {
        AlertViewControllerImage(image: image, tintColor: tintColor)
    }
}
