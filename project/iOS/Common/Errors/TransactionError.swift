//
//  Created by Anton Spivak
//

import Foundation

// MARK: - TransactionError

enum TransactionError {
    case isPending
}

// MARK: LocalizedError

extension TransactionError: LocalizedError {
    var transactionPending: String? {
        switch self {
        case .isPending:
            return "TransactionErrorIsPending".asLocalizedKey
        }
    }
}
