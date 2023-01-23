//
//  Created by Anton Spivak
//

import UIKit

public extension UIImage {
    func redraw(withTintColor tintColor: UIColor) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        tintColor.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
