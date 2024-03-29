//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

// MARK: - VerticalAddressLabelContainerView

final class VerticalAddressLabelContainerView: UIControl {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        clipsToBounds = true
        addSubview(label)

        label.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        label.lineBreakMode = .byClipping
        label.numberOfLines = 1
        label.textAlignment = .left
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var textColor: UIColor = .white {
        didSet {
            label.textColor = textColor
        }
    }

    var address: String = "" {
        didSet {
            label.text = address
        }
    }

    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = label.intrinsicContentSize
        return CGSize(
            width: intrinsicContentSize.height,
            height: UIView.layoutFittingExpandedSize.height
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.bounds = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.width)
        label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        label.transform = .identity.rotated(by: .pi / 2)
    }

    // MARK: Private

    private let label: UILabel = VerticalAddressLabel()
}

// MARK: - VerticalAddressLabel

private class VerticalAddressLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()

        guard let text = text,
              bounds.width > 0
        else {
            return
        }

        let glyphsCount = CGFloat(text.count)
        guard glyphsCount > 1
        else {
            return
        }

        let font = self.font ?? .monospacedSystemFont(ofSize: 16, weight: .regular)
        let glyphWidth = NSAttributedString(string: "s", attributes: [.font: font]).size().width
        let kern = (bounds.width - (glyphsCount * glyphWidth)) / (glyphsCount - 1)

        attributedText = .string(
            text,
            with: .callout,
            kern: kern > 0 ? .custom(value: kern) : .default
        )
    }
}
