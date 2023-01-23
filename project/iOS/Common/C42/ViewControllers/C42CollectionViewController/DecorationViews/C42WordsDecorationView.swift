//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

class C42WordsDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerCurve = .continuous
        layer.cornerRadius = 16

        backgroundColor = .jus_backgroundSecondary
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
