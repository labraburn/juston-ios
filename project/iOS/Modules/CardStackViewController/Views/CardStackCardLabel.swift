//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

final class CardStackCardLabel: UIButton {
    static func createTopButton(_ text: String) -> UIButton {
        let button = CardStackCardLabel(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.insertHighlightingScaleAnimation()
        button.insertFeedbackGenerator(style: .medium)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = .font(for: .caption2)
        button.contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
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
