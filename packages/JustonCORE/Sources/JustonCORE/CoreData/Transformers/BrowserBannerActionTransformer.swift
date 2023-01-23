//
//  Created by Anton Spivak
//

import CoreData
import Foundation

// MARK: - BrowserBannerActionTransformer

internal class BrowserBannerActionTransformer: GenericCodableTransformer<BrowserBannerAction> {
    static func register() {
        ValueTransformer.setValueTransformer(
            BrowserBannerActionTransformer(),
            forName: .BrowserBannerActionTransformer
        )
    }
}

private extension NSValueTransformerName {
    static let BrowserBannerActionTransformer =
        NSValueTransformerName(rawValue: "BrowserBannerActionTransformer")
}
