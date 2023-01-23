//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

// MARK: - Safari3SearchCollectionViewLayoutDelegate

protocol Safari3SearchCollectionViewLayoutDelegate: AnyObject {
    func safari3SearchCollectionViewSectionForIndex(
        index: Int
    ) -> Safari3SearchDataSource.Section?
}

// MARK: - Safari3SearchCollectionViewLayout

class Safari3SearchCollectionViewLayout: CollectionViewCompositionalLayout {
    // MARK: Lifecycle

    override init() {
        super.init()
        refreshLayoutConfiguration(pinToVisibleBounds: false)
    }

    // MARK: Internal

    weak var delegate: Safari3SearchCollectionViewLayoutDelegate?

    override func section(
        forIndex index: Int,
        withEnvironmant environmnet: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        guard let section = delegate?.safari3SearchCollectionViewSectionForIndex(index: index)
        else {
            fatalError("[Safari3SearchCollectionViewLayout]: Can't identifiy index: \(index)")
        }

        let leadingTrailingPadding = CGFloat(18)

        switch section {
        case .empty, .initial:
            let placeholderItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(
                        Safari3SearchPlaceholderCollectionReusableView
                            .estimatedHeight
                    )
                ),
                elementKind: String(
                    describing: Safari3SearchPlaceholderCollectionReusableView
                        .self
                ),
                alignment: .top
            )
            placeholderItem.zIndex = -1

            let section: NSCollectionLayoutSection = .zero
            section.boundarySupplementaryItems = [
                placeholderItem,
            ]

            return section
        case .favourites:
            let spacing = CGFloat(12)

            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(Safari3SearchCollectionViewCell.estimatedHeight)
            )

            let item = NSCollectionLayoutItem(
                layoutSize: size
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: size,
                subitem: item,
                count: 1
            )

            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.supplementariesFollowContentInsets = true
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: leadingTrailingPadding,
                bottom: 16,
                trailing: leadingTrailingPadding
            )

            return section
        }
    }

    func refreshLayoutConfiguration(pinToVisibleBounds: Bool) {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        self.configuration = configuration
    }
}
