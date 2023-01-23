//
//  Created by Anton Spivak
//

import Foundation
import JustonCORE

struct WKWeb3ChainChangedEmit: WKWeb3Emit {
    // MARK: Lifecycle

    init(
        chain: String
    ) {
        self.chain = chain
    }

    // MARK: Internal

    enum CodingKeys: CodingKey {
        case chainID
    }

    static var names: [String] {
        ["chainChanged"]
    }

    let chain: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(chain, forKey: .chainID)
    }
}
