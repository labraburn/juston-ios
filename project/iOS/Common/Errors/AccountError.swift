//
//  Created by Anton Spivak
//

import Foundation

// MARK: - AccountError

enum AccountError {
    case accountExists(name: String)
}

// MARK: LocalizedError

extension AccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .accountExists(name):
            return String(format: "AccountErrorAccountExists".asLocalizedKey, name)
        }
    }
}
