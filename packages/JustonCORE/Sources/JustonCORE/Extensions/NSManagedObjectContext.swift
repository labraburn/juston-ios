//
//  Created by Anton Spivak
//

import CoreData

extension NSManagedObjectContext {
    func perform<T>(_ block: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation({ continuation in
            var result: Result<T, Error> = .failure(CocoaError(.coreData))
            performAndWait({
                do {
                    let value = try block()
                    result = .success(value)
                } catch {
                    result = .failure(error)
                }
            })
            continuation.resume(with: result)
        })
    }
}
