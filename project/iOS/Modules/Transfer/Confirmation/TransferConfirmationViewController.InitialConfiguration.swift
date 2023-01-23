//
//  Created by Anton Spivak
//

import Foundation
import JustonCORE
import SwiftyTON

extension TransferConfirmationViewController {
    struct InitialConfiguration {
        let fromAccount: PersistenceAccount
        let toAddress: DisplayableAddress
        let amount: Currency
        var message: Message
        var estimatedFees: Currency
    }
}
