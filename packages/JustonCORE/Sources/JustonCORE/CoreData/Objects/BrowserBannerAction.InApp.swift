//
//  Created by Anton Spivak
//

import Foundation

public extension BrowserBannerAction {
    enum InApp: String {
        case web3promo
    }
}

// MARK: - BrowserBannerAction.InApp + Hashable

extension BrowserBannerAction.InApp: Hashable {}
