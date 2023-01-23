//
//  Created by Anton Spivak
//

import Foundation

public struct FailableDecodable<T: Decodable>: Decodable {
    // MARK: Lifecycle

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        self.value = try? container.decode(T.self)
    }

    // MARK: Public

    public let value: T?
}
