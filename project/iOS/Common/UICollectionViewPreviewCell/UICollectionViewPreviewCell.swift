//
//  Created by Anton Spivak
//

import UIKit

// MARK: - UICollectionViewPreviewCell

protocol UICollectionViewPreviewCell: UICollectionViewCell {
    var contextMenuPreviewView: UIView? { get }
}

extension UICollectionViewPreviewCell {
    var contextMenuPreviewView: UIView? { self }
}
