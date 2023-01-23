//
//  Created by Anton Spivak
//

import CoreData
import Foundation

// MARK: - SynchronizationLoopGlobalActor

@globalActor
public final actor SynchronizationLoopGlobalActor: GlobalActor {
    public static var shared = SynchronizationLoopActor()
}

// MARK: - SynchronizationLoopActor

public final actor SynchronizationLoopActor: Actor {
    // MARK: Lifecycle

    public init() {
        let dispatchQueue = DispatchQueue(
            label: "com.juston.core.synchronization-loop-actor",
            qos: .utility
        )
        self.executor = DispatchExecutor(dispatchQueue: dispatchQueue)
    }

    // MARK: Public

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    // MARK: Private

    private let executor: DispatchExecutor
}
