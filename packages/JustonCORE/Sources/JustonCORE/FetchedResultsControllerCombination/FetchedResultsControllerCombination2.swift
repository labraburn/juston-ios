//
//  Created by Anton Spivak
//

import CoreData
import UIKit

// MARK: - FetchedResultsControllerCombination2

@MainActor
final public class FetchedResultsControllerCombination2<S1, I1, S2, I2>: NSObject,
    NSFetchedResultsControllerDelegate
    where S1: Hashable, I1: NSFetchRequestResult & Hashable, S2: Hashable,
    I2: NSFetchRequestResult & Hashable
{
    // MARK: Lifecycle

    public init(
        _ f1: NSFetchedResultsController<I1>,
        _ f2: NSFetchedResultsController<I2>,
        results: @escaping FetchedResults
    ) {
        self.f1 = f1
        self.f2 = f2

        self.results = results
        super.init()

        f1.delegate = self
        f2.delegate = self
    }

    // MARK: Public

    public typealias DataSourceSnapshot1 = NSDiffableDataSourceSnapshot<S1, NSManagedObjectID>
    public typealias DataSourceSnapshot2 = NSDiffableDataSourceSnapshot<S2, NSManagedObjectID>

    public typealias FetchedResults = @MainActor (
        _ s1: DataSourceSnapshot1,
        _ s2: DataSourceSnapshot2
    )
        -> Void

    public func performFetch() throws {
        try f1.performFetch()
        try f2.performFetch()
    }

    // MARK: NSFetchedResultsControllerDelegate

    public nonisolated func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
    ) {
        Task { @MainActor in
            switch controller {
            case f1:
                c1 = snapshot as NSDiffableDataSourceSnapshot<S1, NSManagedObjectID>
            case f2:
                c2 = snapshot as NSDiffableDataSourceSnapshot<S2, NSManagedObjectID>
            default:
                break
            }
        }
    }

    // MARK: Private

    private let f1: NSFetchedResultsController<I1>
    private let f2: NSFetchedResultsController<I2>

    private let results: FetchedResults

    private var c1: NSDiffableDataSourceSnapshot<S1, NSManagedObjectID>? { didSet { trigger() } }
    private var c2: NSDiffableDataSourceSnapshot<S2, NSManagedObjectID>? { didSet { trigger() } }

    private func trigger() {
        // Trigger first only when two snapshots exists
        guard let c1 = c1,
              let c2 = c2
        else {
            return
        }

        results(c1, c2)
    }
}

// MARK: - NSDiffableDataSourceSnapshotReference + Sendable

extension NSDiffableDataSourceSnapshotReference: @unchecked Sendable {}
