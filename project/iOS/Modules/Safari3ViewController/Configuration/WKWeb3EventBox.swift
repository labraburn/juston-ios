//
//  Created by Anton Spivak
//

import JustonCORE
import UIKit

struct WKWeb3EventBox {
    // MARK: Lifecycle

    init<T>(
        _ value: T.Type
    ) where T: WKWeb3Event, T.B: Decodable, T.R: Encodable {
        self.names = T.names
        self.process = { account, context, url, value, decoder, encoder in
            let decoded = try decoder.decode(T.B.self, from: value)
            let result = try await T().process(
                account: account,
                context: context,
                url: url,
                decoded
            )

            return try encoder.encode(
                result
            )
        }
    }

    // MARK: Internal

    let names: [String]
    let process: (
        _ account: PersistenceAccount?,
        _ context: UIViewController,
        _ url: URL,
        _ value: Data,
        _ decoder: JSONDecoder,
        _ encoder: JSONEncoder
    ) async throws -> Data
}
