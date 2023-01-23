//
//  Created by Anton Spivak
//

import Foundation
import LocalAuthentication

extension LAContext {
    @MainActor
    func evaluate(
        operation: LAAccessControlOperation,
        accessControl: SecAccessControl,
        localizedReason: String
    ) async throws {
        try await withCheckedThrowingContinuation(
            { (continuation: CheckedContinuation<Void, Error>) in
                self.evaluateAccessControl(
                    accessControl,
                    operation: operation,
                    localizedReason: localizedReason,
                    reply: { _, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                )
            }
        )
    }
}
