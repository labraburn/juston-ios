//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

class C42LogoHeaderView: UICollectionReusableView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .jus_backgroundPrimary
        clipsToBounds = true

        addSubview(imageView)

        NSLayoutConstraint.activate({
            imageView.topAnchor.pin(to: topAnchor)
            imageView.centerXAnchor.pin(to: centerXAnchor)
            bottomAnchor.pin(to: imageView.bottomAnchor)
        })

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 3
        tapGestureRecognizer.addTarget(self, action: #selector(tapGestureRecognizerDidAction(_:)))

        addGestureRecognizer(tapGestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var action: (() -> Void)?

    let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.pin(to: 128).isActive = true
        $0.widthAnchor.pin(to: 128).isActive = true
        $0.image = .jus_appIcon128
    })

    // MARK: Private

    // MARK: Actions

    @objc
    private func tapGestureRecognizerDidAction(_ sender: UITapGestureRecognizer) {
        action?()
    }
}
