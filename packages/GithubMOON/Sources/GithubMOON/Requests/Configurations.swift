//
//  Created by Anton Spivak
//

import Foundation
import JustonMOON

// MARK: - Configurations

public struct Configurations {}

/// GET
public extension Configurations {
    struct GET: Request {
        // MARK: Lifecycle

        public init() {
            self.parameters = Data()
        }

        // MARK: Public

        public typealias R = Answer

        public let endpoint: String = "index.json"
        public let kind: Kind = .GET
        public let parameters: Encodable
    }
}
