//
//  Created by Anton Spivak
//

import CoreData
import Foundation
import SwiftyTON

// MARK: - PersistenceProcessedAction

@objc(PersistenceProcessedAction)
public class PersistenceProcessedAction: PersistenceObject {}

// MARK: - CoreData Properties

public extension PersistenceProcessedAction {
    var sourceAddress: ConcreteAddress? {
        get {
            guard let string = raw_source_address,
                  let address = Address(rawValue: string)
            else {
                return nil
            }

            return ConcreteAddress(
                address: address,
                representation: .base64url(flags: [.bounceable])
            )
        }
        set {
            raw_source_address = newValue?.address.rawValue
        }
    }

    var destinationAddress: ConcreteAddress? {
        get {
            guard let string = raw_destination_address,
                  let address = Address(rawValue: string)
            else {
                return nil
            }

            return ConcreteAddress(
                address: address,
                representation: .base64url(flags: [.bounceable])
            )
        }
        set {
            raw_destination_address = newValue?.address.rawValue
        }
    }

    var value: Currency {
        get { Currency(value: raw_value) }
        set { raw_value = newValue.value }
    }

    var fees: Currency {
        get { Currency(value: raw_fees) }
        set { raw_fees = newValue.value }
    }

    var body: Data {
        get { Data(hex: raw_body) }
        set { raw_body = newValue.toHexString() }
    }

    var bodyHash: Data {
        get { Data(hex: raw_body_hash) }
        set { raw_body_hash = newValue.toHexString() }
    }

    // MARK: Internal

    /// HEX of transaction body
    @NSManaged
    private var raw_body: String

    /// HEX of transaction body
    @NSManaged
    private var raw_body_hash: String

    /// Raw addresses like `[0:346576878]`
    @NSManaged
    private var raw_destination_address: String?

    /// Raw addresses like `[0:346576878]`
    @NSManaged
    private var raw_source_address: String?

    /// nanotons
    @NSManaged
    private var raw_value: Int64

    /// nanotons
    @NSManaged
    private var raw_fees: Int64
}

// MARK: - CoreData Methods

public extension PersistenceProcessedAction {
    @nonobjc
    class func fetchRequest() -> NSFetchRequest<PersistenceProcessedAction> {
        return NSFetchRequest<PersistenceProcessedAction>(entityName: "ProcessedAction")
    }

    @nonobjc
    class func fetchRequest(
        account: PersistenceAccount
    ) -> NSFetchRequest<PersistenceProcessedAction> {
        let request = NSFetchRequest<PersistenceProcessedAction>(entityName: "ProcessedAction")
        return request
    }
}
