//
//  Created by Anton Spivak
//

import DeclarativeUI
import UIKit

open class SignboardView: UIView {
    // MARK: Lifecycle

    public init(letters: [SignboardLetter]) {
        self.letters = letters
        super.init(frame: .zero)

        backgroundColor = .clear
        addSubview(horizontalStackView)

        NSLayoutConstraint.activate {
            horizontalStackView.pin(edges: self)
        }

        letters.forEach({ letter in
            let imageView = SignboardImageView(letter: letter)
            imageView.contentMode = .scaleAspectFit
            horizontalStackView.addArrangedSubview(imageView)

            let multiplier = imageView.size.width / imageView.size.height
            NSLayoutConstraint.activate {
                imageView.widthAnchor.pin(
                    to: horizontalStackView.heightAnchor,
                    multiplier: multiplier
                )
            }
        })
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Open

    // MARK: API

    open func performUpdatesWithLetters(
        _ block: (_ updates: SignboardUpdates) -> Void,
        completion: ((_ finished: Bool) -> Void)? = nil
    ) {
        endUpdates()

        let updates = SignboardUpdates(letters: letters)
        updates.completion = { finished in
            completion?(finished)
        }

        block(updates)
    }

    open func endUpdates() {
        horizontalStackView.arrangedSubviews.forEach({
            $0.layer.recursivelyRemoveAllAnimations()
        })
    }

    // MARK: Public

    public private(set) var letters: [SignboardLetter]

    // MARK: Private

    private let horizontalStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.backgroundColor = .clear
        $0.spacing = 18
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    })
}
