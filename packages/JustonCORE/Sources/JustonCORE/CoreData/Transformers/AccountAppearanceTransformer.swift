//
//  Created by Anton Spivak
//

import CoreData
import Foundation

// MARK: - AccountAppearanceTransformer

internal class AccountAppearanceTransformer: GenericCodableTransformer<AccountAppearance> {
    static func register() {
        ValueTransformer.setValueTransformer(
            AccountAppearanceTransformer(),
            forName: .AccountAppearanceTransformer
        )
    }
}

private extension NSValueTransformerName {
    static let AccountAppearanceTransformer =
        NSValueTransformerName(rawValue: "AccountAppearanceTransformer")
}
