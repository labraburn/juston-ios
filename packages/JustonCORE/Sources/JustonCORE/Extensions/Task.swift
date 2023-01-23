//
//  Created by Anton Spivak
//

import Foundation

public extension Task where Success == Void, Failure == Never {
    @discardableResult
    static func detachedInfinityLoop(
        priority: TaskPriority? = nil,
        delay: TimeInterval = 3,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task<Success, Failure> {
        Task.detached(priority: priority) {
            while true {
                do {
                    try Task<Never, Never>.checkCancellation()
                    try await operation()
                    try await Task<Never, Never>.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                } catch is CancellationError {
                    break
                } catch {
                    print(error)
                    continue
                }
            }
        }
    }
}
