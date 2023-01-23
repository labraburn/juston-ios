//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

class TransactionsDateReusableView: UICollectionReusableView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .jus_backgroundPrimary

        addSubview(textLabel)
        NSLayoutConstraint.activate({
            textLabel.topAnchor.pin(to: topAnchor, constant: 0)
            textLabel.pin(horizontally: self, left: 12, right: 12)
            bottomAnchor.pin(to: textLabel.bottomAnchor, constant: 0)

            heightAnchor.pin(greaterThan: Self.estimatedHeight)
        })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    typealias Model = String

    static let estimatedHeight: CGFloat = 14

    var model: Model? {
        didSet {
            guard model != oldValue
            else {
                return
            }

            update(model: model)
        }
    }

    // MARK: Private

    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .caption1)
        $0.textColor = .jus_textPrimary.withAlphaComponent(0.38)
        $0.textAlignment = .center
    })

    private func update(model: Model?) {
        textLabel.text = model
    }
}
