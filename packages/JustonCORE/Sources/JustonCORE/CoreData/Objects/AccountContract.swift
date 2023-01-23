//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON

public struct AccountContract {
    // MARK: Lifecycle

    public init(
        address: Address,
        kind: Contract.Kind?
    ) {
        self.address = address
        self.kind = kind
    }

    // MARK: Public

    public let address: Address
    public let kind: Contract.Kind?
}
