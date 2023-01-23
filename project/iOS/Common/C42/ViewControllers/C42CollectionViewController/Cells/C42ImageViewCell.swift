//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

class C42ImageViewCell: UICollectionViewCell {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = .jus_backgroundPrimary
        contentView.addSubview(imageView)

        imageView.pinned(edges: contentView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    // MARK: Private

    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.pin(to: $0.widthAnchor).isActive = true
    })
}
