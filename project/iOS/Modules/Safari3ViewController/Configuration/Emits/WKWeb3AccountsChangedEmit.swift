//
//  Created by Anton Spivak
//

import Foundation
import JustonCORE

struct WKWeb3AccountsChangedEmit: WKWeb3Emit {
    // MARK: Lifecycle

    init(
        accounts: [PersistenceAccount]
    ) {
        self.accounts = accounts.map({
            $0.convienceSelectedAddress.description
        })
    }

    // MARK: Internal

    static var names: [String] {
        ["accountsChanged"]
    }

    let accounts: [String]

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(accounts)
    }
}
