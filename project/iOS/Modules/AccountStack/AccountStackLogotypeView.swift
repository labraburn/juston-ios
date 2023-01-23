//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

final class AccountStackLogotypeView: UIControl {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        backgroundColor = .clear
        addSubview(justonView)
        justonView.pinned(edges: self)

        insertHighlightingScaleAnimation()
        insertFeedbackGenerator(style: .light)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let justonView = JustonView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
    })
}
