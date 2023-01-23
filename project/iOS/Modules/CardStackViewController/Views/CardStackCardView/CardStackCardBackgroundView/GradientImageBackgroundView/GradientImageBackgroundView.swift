//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

class GradientImageBackgroundView: UIView, CardStackCardBackgroundContentView {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        _init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }

    // MARK: Internal

    var borderColor: UIColor = .white.withAlphaComponent(0) {
        didSet {
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = borderColor.cgColor
            setNeedsLayout()
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            imageView.layer.cornerRadius = cornerRadius
            imageView.layer.cornerCurve = .continuous
            setNeedsLayout()
        }
    }

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }

    // MARK: Private

    private let imageView: UIImageView = .init().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleToFill
        $0.clipsToBounds = true
    })

    private func _init() {
        addSubview(imageView)
        imageView.pinned(edges: self)
        clipsToBounds = false
    }
}
