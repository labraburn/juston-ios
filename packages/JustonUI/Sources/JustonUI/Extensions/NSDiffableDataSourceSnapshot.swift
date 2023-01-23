//
//  Created by Anton Spivak
//

import UIKit

public extension NSDiffableDataSourceSnapshot {
    mutating func appendSection(
        _ sectionIdentifier: SectionIdentifierType,
        items: [ItemIdentifierType]
    ) {
        appendSections([sectionIdentifier])
        appendItems(items, toSection: sectionIdentifier)
    }
}
