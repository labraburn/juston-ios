//
//  Created by Anton Spivak
//

import UIKit

public extension UICollectionView {
    func register(reusableCellClass klass: UICollectionViewCell.Type) {
        register(klass, forCellWithReuseIdentifier: klassIdentifier(for: klass))
    }

    func dequeue<T: UICollectionViewCell>(
        reusableCellClass klass: T.Type,
        for indexPath: IndexPath
    ) -> T {
        let identifier = klassIdentifier(for: klass)
        guard let view = dequeueReusableCell(
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? T
        else {
            fatalError("Reusable cell `\(identifier)` did not registered")
        }
        return view
    }

    func register(
        reusableSupplementaryViewClass klass: UICollectionReusableView.Type,
        elementKind: String? = nil
    ) {
        let identifier = klassIdentifier(for: klass)
        register(
            klass,
            forSupplementaryViewOfKind: elementKind ?? identifier,
            withReuseIdentifier: identifier
        )
    }

    func dequeue<T: UICollectionReusableView>(
        reusableSupplementaryViewClass klass: T.Type,
        elementKind: String? = nil,
        for indexPath: IndexPath
    ) -> T {
        let identifier = klassIdentifier(for: klass)
        guard let view = dequeueReusableSupplementaryView(
            ofKind: elementKind ?? identifier,
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? T
        else {
            fatalError("Reusable supplementary view `\(identifier)` did not registered")
        }
        return view
    }
}

public extension UICollectionViewLayout {
    func register(
        reusableDecorationViewOfKind klass: UICollectionReusableView.Type,
        elementKind: String? = nil
    ) {
        let identifier = elementKind ?? klassIdentifier(for: klass)
        register(klass, forDecorationViewOfKind: identifier)
    }
}

public extension UICollectionView {
    func indexPath(
        for supplementaryView: UICollectionReusableView?,
        ofKind kind: String
    ) -> IndexPath? {
        let elements = visibleSupplementaryViews(ofKind: kind)
        let indexPaths = indexPathsForVisibleSupplementaryElements(ofKind: kind)

        for (element, indexPath) in zip(elements, indexPaths) where element === supplementaryView {
            return indexPath
        }

        return nil
    }
}

private func klassIdentifier(for klass: AnyClass) -> String {
    String(describing: klass)
}
