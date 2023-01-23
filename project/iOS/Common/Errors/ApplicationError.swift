//
//  Created by Anton Spivak
//

import Foundation

// MARK: - ApplicationError

enum ApplicationError {
    case noApplicationPassword
    case userCancelled
}

// MARK: LocalizedError

extension ApplicationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noApplicationPassword:
            return "ApplicationErrorPasscodeNotSet".asLocalizedKey
        case .userCancelled:
            return ""
        }
    }
}
