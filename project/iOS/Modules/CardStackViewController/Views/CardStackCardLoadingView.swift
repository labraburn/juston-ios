//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

final class CardStackCardLoadingView: UIView {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.pin(to: 24).isActive = true
        widthAnchor.pin(to: 24).isActive = true
        backgroundColor = .clear

        layer.cornerRadius = 12
        layer.cornerCurve = .circular
        layer.masksToBounds = true

        addSubview(imageView)
        imageView.pinned(edges: self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let imageView = UIImageView().with({ imageView in
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(
            systemName: "arrow.up.and.down.circle",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 20,
                weight: .regular
            )
        )
        imageView.contentMode = .center
        imageView.tintColor = .white.withAlphaComponent(0.5)
    })

    func setLoading(_ flag: Bool, delay: TimeInterval = 1.42) {
        isLoading = flag

        if flag {
            startLoadingAnimation(delay: delay, fade: false)
            startRotationAnimation()
        } else {
            stopRotationAnimation()
            stopLoadingAnimation()
        }
    }

    override func didMoveToWindow() {
        setLoading(
            isLoading && window != nil,
            delay: 0.42
        )
    }

    // MARK: Private

    private var isLoading: Bool = false

    private func startRotationAnimation() {
        // OverlayLoadingView
        guard subviews.last?.layer.animation(forKey: "rotation") == nil
        else {
            return
        }

        subviews.last?.layer.add({
            let animation = CABasicAnimation(keyPath: "transform.rotation")
            animation.fromValue = 0
            animation.toValue = Float.pi * 2
            animation.duration = 4.2
            animation.repeatCount = .infinity
            return animation
        }(), forKey: "rotation")
    }

    private func stopRotationAnimation() {
        subviews.last?.layer.removeAnimation(forKey: "rotation")
    }
}
