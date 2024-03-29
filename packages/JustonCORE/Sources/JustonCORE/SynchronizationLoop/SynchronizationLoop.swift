//
//  Created by Anton Spivak
//

import CoreData
import Foundation
import SwiftyTON

// MARK: - SynchronizationLoop

@SynchronizationLoopGlobalActor
public final class SynchronizationLoop {
    // MARK: Lifecycle

    nonisolated public init() {}

    deinit {
        task?.cancel()
    }

    // MARK: Public

    public nonisolated func use(
        address: Address?
    ) {
        Task { @SynchronizationLoopGlobalActor in
            guard self.address != address
            else {
                return
            }

            self.address = address
            self.restart()
        }
    }

    // MARK: Private

    private var address: Address?
    private var task: Task<Void, Never>?

    private func restart(
    ) {
        let address = address

        task?.cancel()
        task = Task.detachedInfinityLoop(
            delay: 3,
            operation: { @SynchronizationLoopGlobalActor [weak self] in
                try await self?.loop(address: address)
            }
        )
    }

    @PersistenceWritableActor
    private func loop(
        address: Address?
    ) async throws {
        try Task.checkCancellation()

        let context = PersistenceWritableActor.shared.managedObjectContext
        guard let address = address,
              let persistenceAccount = try account(forSelectedAddress: address, in: context)
        else {
            return
        }

        persistenceAccount.isSynchronizing = true
        try context.save()

        defer {
            persistenceAccount.isSynchronizing = false
            try? context.save()
        }

        let contract = try await Contract(address: address)
        try Task.checkCancellation()

        persistenceAccount.balance = contract.info.balance
        persistenceAccount.contractKind = contract.kind

        try context.save()

        let lastProcessedTransaction = try lastPersistanceProcessedTransaction(
            for: persistenceAccount,
            in: context
        )
        let pendingPersistanceTransactions = try persistancePendingTransaction(
            for: persistenceAccount,
            in: context
        )

        let transactions: [Transaction] = try await contract
            .transactions(after: lastProcessedTransaction?.id)
        try Task.checkCancellation()

        transactions.forEach({ transaction in

            // Remove pending transactions with same body hash value
            if let message = transaction.in {
                pendingPersistanceTransactions
                    .filter({ $0.bodyHash == message.bodyHash })
                    .forEach({ context.delete($0) })
            }

            let persistenceTransaction = PersistenceProcessedTransaction(context: context)
            persistenceTransaction.id = transaction.id
            persistenceTransaction.account = persistenceAccount
            persistenceTransaction.date = transaction.date
            persistenceTransaction.fees = transaction.storageFee + transaction.otherFee

            if let message = transaction.in {
                let action = PersistenceProcessedAction(message: message, in: context)
                persistenceTransaction.in = action
            }

            let out = transaction.out.compactMap({
                PersistenceProcessedAction(message: $0, in: context)
            })

            persistenceTransaction.out = Set(out)
        })

        persistenceAccount.dateLastSynchronization = Date()
        persistenceAccount.isSynchronizing = false

        try context.save()
    }

    // MARK: Helpers

    @PersistenceWritableActor
    private func account(
        forSelectedAddress address: Address,
        in context: NSManagedObjectContext
    ) throws -> PersistenceAccount? {
        let request = PersistenceAccount.fetchRequest(selectedAddress: address)
        let result = try context.fetch(request)
        return result.last
    }

    @PersistenceWritableActor
    private func lastPersistanceProcessedTransaction(
        for account: PersistenceAccount,
        in context: NSManagedObjectContext
    ) throws -> PersistenceProcessedTransaction? {
        let request = PersistenceProcessedTransaction.fetchRequest(account: account)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        let result = try context.fetch(request)
        return result.last
    }

    @PersistenceWritableActor
    private func persistancePendingTransaction(
        for account: PersistenceAccount,
        in context: NSManagedObjectContext
    ) throws -> [PersistencePendingTransaction] {
        let request = PersistencePendingTransaction.fetchRequest(account: account)
        return try context.fetch(request)
    }
}

private extension PersistenceProcessedAction {
    convenience init(
        message: Transaction.Message,
        in context: NSManagedObjectContext
    ) {
        self.init(context: context)

        if let sourceAccountAddress = message.sourceAccountAddress {
            sourceAddress = ConcreteAddress(
                address: sourceAccountAddress.address,
                representation: .base64url(flags: [.bounceable])
            )
        }

        if let destinationAccountAddress = message.destinationAccountAddress {
            destinationAddress = ConcreteAddress(
                address: destinationAccountAddress.address,
                representation: .base64url(flags: [.bounceable])
            )
        }

        value = message.value
        fees = message.fees

        switch message.body {
        case let .data(data):
            body = data
        case let .text(value):
            body = Data(value.bytes)
        case .encrypted:
            body = Data()
        }

        bodyHash = message.bodyHash
    }
}
