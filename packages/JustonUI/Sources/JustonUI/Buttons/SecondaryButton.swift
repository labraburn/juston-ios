//
//  Created by Anton Spivak
//

import UIKit

public class SecondaryButton: JustonButton {
    // MARK: Lifecycle

    public init(title: String? = nil) {
        super.init(frame: .zero)
        textLabel.text = title
        _initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _initialize()
    }

    // MARK: Public

    public override var title: String? {
        didSet {
            textLabel.text = title
        }
    }

    public var titleColor: UIColor = .init(rgb: 0x7B66FF) {
        didSet {
            textLabel.textColor = titleColor
        }
    }

    // MARK: Internal

    override func _initialize() {
        super._initialize()

        addSubview(borderView)
        addSubview(textLabel)

        NSLayoutConstraint.activate({
            borderView.pin(edges: self)
            textLabel.pin(edges: self)
        })

        insertFeedbackGenerator(style: .medium)
    }

    // MARK: Private

    private let borderView =
        GradientBorderedView(colors: [UIColor(rgb: 0x4876E6), UIColor(rgb: 0x8D55E9)]).with({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.cornerRadius = 12
        })

    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = UIColor(rgb: 0x7B66FF)
    })
}
