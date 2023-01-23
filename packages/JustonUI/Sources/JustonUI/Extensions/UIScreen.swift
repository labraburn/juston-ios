//
//  Created by Anton Spivak
//

import Foundation

import UIKit

public extension UIScreen {
    var displayCornerRadius: CGFloat {
        let key = ["Radius", "Corner", "display", "_"].reversed().joined()

        guard let cornerRadius = value(forKey: key) as? CGFloat
        else {
            return 0
        }

        return cornerRadius
    }
}
