//
//  Created by Anton Spivak
//

import UIKit

public final class SignboardLetter {
    // MARK: Lifecycle

    public init(
        character: Character,
        color: UIColor,
        tumbler: SignboardTumbler
    ) {
        self.character = character
        self.color = color
        self.tumbler = tumbler
    }

    // MARK: Public

    public let character: Character
    public let color: UIColor

    public var tumbler: SignboardTumbler {
        didSet {
            guard tumbler != oldValue
            else {
                return
            }

            observer?(self)
        }
    }

    // MARK: Internal

    internal var observer: ((_ letter: SignboardLetter) -> Void)?

    internal var tintColor: UIColor {
        switch tumbler {
        case .on:
            return color
        case .off:
            return UIColor(rgb: 0x3C3C3C)
        }
    }
}
