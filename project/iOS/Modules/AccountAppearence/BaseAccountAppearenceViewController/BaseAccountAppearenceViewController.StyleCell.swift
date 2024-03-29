//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

extension BaseAccountAppearenceViewController {
    class StyleCell: UICollectionViewCell {
        // MARK: Lifecycle

        override init(frame: CGRect) {
            super.init(frame: frame)

            clipsToBounds = false
            contentView.addSubview(pin)

            NSLayoutConstraint.activate({
                pin.centerXAnchor.pin(to: contentView.centerXAnchor)
                contentView.bottomAnchor.pin(to: pin.bottomAnchor)
            })
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Internal

        override var isSelected: Bool {
            didSet {
                pin.image = isSelected ? .jus_radioButtonSelected20 : .jus_radioButtonDeselected20
            }
        }

        func fill(with appearance: AccountAppearance) {
            view?.removeFromSuperview()

            let view: CardStackCardBackgroundContentView
            switch appearance.kind {
            case let .glass(gradient0Color, gradient1Color):
                view = GlassBackgroundView(
                    colors: [
                        UIColor(rgba: gradient0Color),
                        UIColor(rgba: gradient1Color),
                    ],
                    effectsSize: .small
                ).with({ view in
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.cornerRadius = 12
                })
            case let .gradientImage(imageData, strokeColor):
                view = GradientImageBackgroundView().with({
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    $0.image = UIImage(data: imageData)
                    $0.borderColor = UIColor(rgba: strokeColor)
                    $0.cornerRadius = 12
                })
            }

            insertSubview(view, at: 0)
            NSLayoutConstraint.activate({
                view.topAnchor.pin(to: contentView.topAnchor)
                view.pin(horizontally: contentView)

                pin.topAnchor.pin(to: view.bottomAnchor, constant: 12)
            })

            self.view = view
        }

        // MARK: Private

        private var view: CardStackCardBackgroundContentView?
        private var pin: UIImageView = .init().with({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.pin(to: 20).isActive = true
            $0.tintColor = .white
            $0.image = .jus_radioButtonDeselected20
        })
    }
}
