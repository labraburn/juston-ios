//
//  Created by Anton Spivak
//

import Foundation

public extension Configurations.Action {
    enum InApp: String {
        case web3promo
    }
}

// MARK: - Configurations.Action.InApp + Decodable

extension Configurations.Action.InApp: Decodable {}

// MARK: - Configurations.Action.InApp + Hashable

extension Configurations.Action.InApp: Hashable {}
