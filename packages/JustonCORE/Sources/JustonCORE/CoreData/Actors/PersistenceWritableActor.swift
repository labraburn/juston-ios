//
//  Created by Anton Spivak
//

import CoreData
import Foundation

// MARK: - PersistenceWritableActor

@globalActor
public final actor PersistenceWritableActor: Actor {
    // MARK: Lifecycle

    public init() {
        let managedObjectContext = PersistenceController.shared.managedObjectContext(
            withType: .writeContext
        )
        self.executor = PersistenceWritableExecutor(managedObjectContext: managedObjectContext)
    }

    // MARK: Public

    public static var shared = PersistenceWritableActor()

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    public nonisolated var managedObjectContext: NSManagedObjectContext {
        executor.managedObjectContext
    }

    // MARK: Private

    private let executor: PersistenceWritableExecutor
}

// MARK: - PersistenceWritableExecutor

private final class PersistenceWritableExecutor: SerialExecutor {
    // MARK: Lifecycle

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // MARK: Internal

    let managedObjectContext: NSManagedObjectContext

    func enqueue(_ job: UnownedJob) {
        let unownedSerialExecutor = asUnownedSerialExecutor()
        managedObjectContext.perform({
            autoreleasepool(invoking: {
                job._runSynchronously(on: unownedSerialExecutor)
            })
        })
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

// MARK: - NSManagedObjectContext + Sendable

extension NSManagedObjectContext: @unchecked Sendable {}
