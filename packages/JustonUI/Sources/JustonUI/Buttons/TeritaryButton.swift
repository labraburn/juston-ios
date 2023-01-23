//
//  Created by Anton Spivak
//

import UIKit

public class TeritaryButton: JustonButton {
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

    // MARK: Internal

    override func _initialize() {
        super._initialize()

        addSubview(textLabel)

        NSLayoutConstraint.activate({
            textLabel.pin(edges: self)
        })

        insertFeedbackGenerator(style: .light)
    }

    // MARK: Private

    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        $0.textAlignment = .center
        $0.textColor = UIColor(rgb: 0x7B66FF)
    })
}
