//
//  Created by Anton Spivak
//

import CoreData
import Foundation

public typealias PersistenceReadableActor = MainActor

public extension PersistenceReadableActor {
    nonisolated var managedObjectContext: NSManagedObjectContext {
        PersistenceController.shared.managedObjectContext(withType: .readContext)
    }
}
