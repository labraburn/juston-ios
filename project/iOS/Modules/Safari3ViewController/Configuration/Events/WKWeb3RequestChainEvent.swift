//
//  Created by Anton Spivak
//

import JustonCORE
import UIKit

struct WKWeb3RequestChainEvent: WKWeb3Event {
    struct Body: Decodable {}

    struct Response: Encodable {
        let chainID: String
    }

    static let names = ["ton_requestChain"]

    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> [Response] {
        return [
            Response(
                chainID: SwiftyTON.configuration.network.rawValue
            ),
        ]
    }
}
