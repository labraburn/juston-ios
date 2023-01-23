//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

class PasscodeNumberButton: UIButton {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    // MARK: Internal

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2
        layer.cornerCurve = .circular
    }

    // MARK: Private

    private func initialize() {
        layer.masksToBounds = true
        titleLabel?.font = .font(for: .title2)
        backgroundColor = UIColor(rgb: 0x1C1924)

        insertFeedbackGenerator(style: .light)
        insertHighlightingScaleAnimation()
    }
}
