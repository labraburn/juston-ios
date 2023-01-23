//
//  Created by Anton Spivak
//

import UIKit

public class BarBackgroundView: UIView {
    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        backgroundColor = .clear
        visualEffectView.backgroundColor = .clear
        self.tintColor = .jus_textSecondary.withAlphaComponent(0.69)

        addSubview(tintView)
        addSubview(visualEffectView)

        NSLayoutConstraint.activate({
            tintView.pin(edges: self)
            visualEffectView.pin(edges: self)
        })
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public let tintView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alpha = 0.86
    })

    override public var tintColor: UIColor! {
        get { tintView.backgroundColor ?? .clear }
        set { tintView.backgroundColor = newValue }
    }

    // MARK: Private

    private let visualEffectView = UIVisualEffectView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.effect = UIBlurEffect(style: .regular)
    })
}
