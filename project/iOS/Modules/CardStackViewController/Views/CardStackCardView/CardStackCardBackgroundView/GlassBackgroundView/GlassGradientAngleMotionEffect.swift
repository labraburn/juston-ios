//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

// MARK: - SharedGlassGradientAngleMotionEffectView

class SharedGlassGradientAngleMotionEffectView: UIView {
    // MARK: Lifecycle

    private init() {
        super.init(frame: .zero)

        let effect = GlassGradientAngleMotionEffect(effectView: self)

        frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        backgroundColor = .clear
        addMotionEffect(effect)

        let window = Application.shared.connectedApplicationWindowScenes.first?.window
        window?.addSubview(self)
        window?.sendSubviewToBack(self)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    static let shared = SharedGlassGradientAngleMotionEffectView()

    var angle: Double {
        get { _angle }
        set { _angle = newValue.truncatingRemainder(dividingBy: 360) }
    }

    func addGradientView(_ gradientView: GradientView) {
        gradientViews.add(gradientView)
    }

    // MARK: Private

    private let gradientViews: NSHashTable<GradientView> = .weakObjects()

    private var _angle: Double = 0 {
        didSet {
            guard _angle != oldValue
            else {
                return
            }

            UIView.animate(withDuration: 1.42, delay: 0, options: [.curveEaseOut], animations: {
                self.gradientViews.allObjects.forEach({ $0.angle = self._angle })
            }, completion: nil)
        }
    }
}

// MARK: - GlassGradientAngleMotionEffect

class GlassGradientAngleMotionEffect: UIMotionEffect {
    // MARK: Lifecycle

    init(effectView: SharedGlassGradientAngleMotionEffectView) {
        self.effectView = effectView
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    private(set) weak var effectView: SharedGlassGradientAngleMotionEffectView?

    override func keyPathsAndRelativeValues(forViewerOffset viewerOffset: UIOffset)
        -> [String: Any]?
    {
        guard let effectView = effectView
        else {
            return nil
        }

        let p1 = CGPoint(x: viewerOffset.horizontal, y: viewerOffset.vertical)
        let p2 = CGPoint(x: 1, y: 0)

        let dY = p1.y - p2.y
        let dX = p2.x - p1.x
        var angle = atan2(dY, dX) * 180 / .pi

        if angle < 0 {
            angle += 360
        }

        effectView.angle = angle

        return nil
    }
}
