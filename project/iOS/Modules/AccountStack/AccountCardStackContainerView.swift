//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

class AccountCardStackContainerView: ContainerView<CardStackView> {
    override var enclosingView: CardStackView? {
        didSet {
            enclosingView?.translatesAutoresizingMaskIntoConstraints = false
            guard let enclosingView = enclosingView
            else {
                return
            }

            addSubview(enclosingView)
            NSLayoutConstraint.activate({
                enclosingView.pin(horizontally: self)
                enclosingView.centerYAnchor.pin(
                    to: centerYAnchor,
                    priority: .required
                )
                enclosingView.heightAnchor.pin(
                    to: enclosingView.widthAnchor,
                    multiplier: 1.585772,
                    priority: .required - 1
                )

                enclosingView.topAnchor.pin(greaterThan: topAnchor, priority: .required)
                bottomAnchor.pin(greaterThan: enclosingView.bottomAnchor, priority: .required)
            })
        }
    }

    override func layoutSubviews() {
//        yes, it's right
//        super.layoutSubviews()
        layoutCornerRadius()
    }

    func layoutCornerRadius() {
        guard let enclosingView = enclosingView
        else {
            return
        }

        enclosingView.cornerRadius = enclosingView.bounds.height * 0.0399
    }
}
