//
//  Created by Anton Spivak
//

import CoreData
import Foundation
import ObjectiveC.runtime

// MARK: - PersistenceObjectObserver

public final class PersistenceObjectObserver {
    // MARK: Lifecycle

    fileprivate init() {}

    // MARK: Private

    private let uuid = UUID()
}

// MARK: Hashable

extension PersistenceObjectObserver: Hashable {
    public static func == (lhs: PersistenceObjectObserver, rhs: PersistenceObjectObserver) -> Bool {
        lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

public extension NSManagedObject {
    private final class ObserverContainer {
        // MARK: Lifecycle

        init(_ block: @escaping () -> Void) {
            self.block = block
        }

        // MARK: Internal

        let block: () -> Void
    }

    private enum Keys {
        static var hashtable: UInt8 = 0
    }

    /// Warning - should be called only at main tread
    private var observers: NSMapTable<PersistenceObjectObserver, ObserverContainer> {
        if let value = objc_getAssociatedObject(
            self,
            &Keys.hashtable
        ) as? NSMapTable<PersistenceObjectObserver, ObserverContainer> {
            return value
        } else {
            let value = NSMapTable<PersistenceObjectObserver, ObserverContainer>
                .weakToStrongObjects()
            objc_setAssociatedObject(
                self,
                &Keys.hashtable,
                value,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return value
        }
    }

    /// Warning - should be called only at main tread
    fileprivate func _didUpdateInsideReadableContext() {
        let enumerator = observers.objectEnumerator()
        while let value = enumerator?.nextObject() as? ObserverContainer {
            value.block()
        }
    }

    // MARK: API

    @PersistenceReadableActor
    func addObjectDidChangeObserver(_ observer: @escaping () -> Void) -> PersistenceObjectObserver {
        let key = PersistenceObjectObserver()
        observers.setObject(ObserverContainer(observer), forKey: key)
        return key
    }
}

// MARK: - ManagedObjectContextObjectsDidChangeObserver

internal enum ManagedObjectContextObjectsDidChangeObserver {
    // MARK: Internal

    internal static func startObservingIfNeccessary() {
        guard observer == nil
        else {
            return
        }

        let didSave = { (_ persistenceObject: PersistenceObject) in
            persistenceObject._didUpdateInsideReadableContext()
        }

        let block = { (_ notification: Notification) in
            (notification.userInfo?[NSRefreshedObjectsKey] as? Set<PersistenceObject>)?
                .forEach(didSave)
            (notification.userInfo?[NSUpdatedObjectsKey] as? Set<PersistenceObject>)?
                .forEach(didSave)
        }

        observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: PersistenceReadableActor.shared.managedObjectContext,
            queue: .main,
            using: block
        )
    }

    // MARK: Private

    private static var observer: AnyObject?
}
