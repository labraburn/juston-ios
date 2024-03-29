//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

class TransactionsPlaceholderCollectionReusableView: UICollectionReusableView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .jus_backgroundPrimary

        addSubview(textLabel)
        addSubview(button)

        button.addTarget(self, action: #selector(buttonDidClick(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate({
            textLabel.topAnchor.pin(to: topAnchor, constant: 12)
            textLabel.pin(horizontally: self, left: 36, right: 36)

            button.topAnchor.pin(to: textLabel.bottomAnchor, constant: 24)
            button.pin(horizontally: self, left: 36, right: 36)

            heightAnchor.pin(greaterThan: Self.estimatedHeight)
        })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    static let estimatedHeight: CGFloat = 256

    var action: (() -> Void)?

    // MARK: Private

    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .body)
        $0.text = "TransactionsEmptyTitle".asLocalizedKey
        $0.textColor = .jus_textPrimary
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })

    private let button = SecondaryButton(title: "TransactionsEmptyButton".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    // MARK: Actions

    @objc
    private func buttonDidClick(_ sender: UIControl) {
        action?()
    }
}
