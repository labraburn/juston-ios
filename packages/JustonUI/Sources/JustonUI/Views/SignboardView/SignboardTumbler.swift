//
//  Created by Anton Spivak
//

import UIKit

// MARK: - SignboardTumbler

public enum SignboardTumbler {
    case on
    case off
}

public extension Array where Element == SignboardTumbler {
    static func on(count: Int) -> [Element] {
        Array(repeating: .on, count: count)
    }

    static func off(count: Int) -> [Element] {
        Array(repeating: .off, count: count)
    }
}
