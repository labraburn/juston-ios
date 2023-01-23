//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON

struct TransferConfiguration {
    // MARK: Lifecycle

    init(
        destination: DisplayableAddress,
        amount: Currency? = nil,
        message: String? = nil,
        payload: Data? = nil,
        initial: Data? = nil
    ) {
        self.destination = destination
        self.amount = amount
        self.message = message
        self.payload = payload
        self.initial = initial
    }

    // MARK: Internal

    let destination: DisplayableAddress
    let amount: Currency?
    let message: String?
    let payload: Data?
    let initial: Data?
}
