//
//  Created by Anton Spivak
//

import UIKit

public final class FloatingTabBarItem: UITabBarItem {
    // MARK: Lifecycle

    public convenience init(customView: UIControl) {
        self.init()
        self.customView = customView
    }

    // MARK: Public

    public var customView: UIControl?

    public var selectedTintColor: UIColor?
    public var deselectedTintColor: UIColor?
}
