//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

final class CardStackCardButton: UIButton {
    static func createBottomButton(_ image: UIImage) -> UIButton {
        let button = CardStackCardButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.insertHighlightingScaleAnimation()
        button.insertFeedbackGenerator(style: .medium)

        // Inside UIStackView this helps tp avoid unnecessary errors
        let constraint = button.widthAnchor.pin(to: button.heightAnchor)
        constraint.priority = .required - 1
        constraint.isActive = true

        button.setImage(image, for: .normal)
        button.layer.cornerRadius = 24
        button.layer.cornerCurve = .circular
        return button
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.applyFigmaShadow(
            color: .init(rgb: 0x232020),
            alpha: 0.24,
            x: 0,
            y: 12,
            blur: 12,
            spread: 0,
            cornerRadius: 10
        )
    }
}
