//
//  Created by Anton Spivak
//

import CoreData
import Foundation

public final class DispatchExecutor: SerialExecutor {
    // MARK: Lifecycle

    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }

    // MARK: Public

    public func enqueue(_ job: UnownedJob) {
        let unownedSerialExecutor = asUnownedSerialExecutor()
        dispatchQueue.async(execute: {
            job._runSynchronously(on: unownedSerialExecutor)
        })
    }

    public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }

    // MARK: Internal

    let dispatchQueue: DispatchQueue
}
