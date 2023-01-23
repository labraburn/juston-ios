//
//  Created by Anton Spivak
//

import JustonCORE
import UIKit

struct WKWeb3UndefinedEvent: WKWeb3Event {
    struct Body: Decodable {}
    struct Response: Encodable {}

    static let names = ["_undefined"]

    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: Body
    ) async throws -> Response {
        throw WKWeb3Error(.unsupportedMethod)
    }
}
