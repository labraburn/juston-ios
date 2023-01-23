//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

// MARK: - C42TitleHeaderView

class C42TitleHeaderView: UICollectionReusableView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .jus_backgroundPrimary
        clipsToBounds = true
        addSubview(titleLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var textAligment: NSTextAlignment = .left {
        didSet {
            titleLabel.textAlignment = textAligment
        }
    }

    var foregroundColor: UIColor = .jus_textSecondary {
        didSet {
            titleLabel.textColor = foregroundColor
        }
    }

    // MARK: Fileprivate

    fileprivate let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    })
}

// MARK: - C42ListGroupHeaderView

class C42ListGroupHeaderView: C42TitleHeaderView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .font(for: .caption1)
        titleLabel.textColor = .jus_textSecondary

        NSLayoutConstraint.activate({
            titleLabel.pin(edges: self)
        })
    }
}

// MARK: - C42SimpleGroupHeaderView

class C42SimpleGroupHeaderView: C42TitleHeaderView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .font(for: .headline)
        titleLabel.textColor = .jus_textSecondary

        NSLayoutConstraint.activate({
            titleLabel.pin(edges: self, insets: UIEdgeInsets(top: 0, left: 0, right: 0, bottom: 16))
        })
    }
}
