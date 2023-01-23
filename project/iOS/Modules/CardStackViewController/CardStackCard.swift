//
//  Created by Anton Spivak
//

import Foundation
import JustonCORE

// MARK: - CardStackCard

@MainActor
struct CardStackCard {
    let account: PersistenceAccount
}

// MARK: Hashable

extension CardStackCard: Hashable {
    static func == (lhs: CardStackCard, rhs: CardStackCard) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(account.selectedContract.address)
    }
}
