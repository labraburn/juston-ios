//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

class GlassBackgroundView: UIView, CardStackCardBackgroundContentView {
    // MARK: Lifecycle

    init(
        colors: [UIColor],
        effectsSize: EffectsSize = .large
    ) {
        self.effectsSize = effectsSize
        self.lumineView = GlassBackgroundLumineView(
            colors: colors,
            lineWidth: effectsSize.lineWidth
        ).with({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })

        super.init(frame: .zero)
        _init()
    }

    required init?(
        coder: NSCoder
    ) {
        self.effectsSize = .large
        self.lumineView = GlassBackgroundLumineView(
            colors: [.cyan, .magenta],
            lineWidth: EffectsSize.large.lineWidth
        ).with({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })

        super.init(coder: coder)
        _init()
    }

    // MARK: Internal

    enum EffectsSize {
        case small
        case large

        // MARK: Fileprivate

        fileprivate var blurEffect: UIBlurEffect {
            switch self {
            case .small: return UIBlurEffect(radius: 10, scale: 100)
            case .large: return UIBlurEffect(radius: 67, scale: 100)
            }
        }

        fileprivate var lineWidth: CGFloat {
            switch self {
            case .small: return 6
            case .large: return 18
            }
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            lumineView.cornerRadius = cornerRadius
            visualEffectView.layer.cornerRadius = cornerRadius
        }
    }

    // MARK: Private

    private lazy var borderView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private lazy var visualEffectView = UIVisualEffectView(effect: effectsSize.blurEffect).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private let lumineView: GlassBackgroundLumineView
    private let effectsSize: EffectsSize

    private func _init() {
        lumineView.cornerRadius = cornerRadius
        addSubview(lumineView)

        visualEffectView.layer.masksToBounds = true
        visualEffectView.layer.cornerCurve = .continuous
        visualEffectView.layer.cornerRadius = cornerRadius
        addSubview(visualEffectView)

        NSLayoutConstraint.activate {
            lumineView.pin(edges: self)
            visualEffectView.pin(edges: self)
        }
    }
}
