//
//  Created by Anton Spivak
//

import JustonCORE
import UIKit

protocol WKWeb3Event {
    associatedtype B = Decodable
    associatedtype R = Encodable

    static var names: [String] { get }

    init()

    func process(
        account: PersistenceAccount?,
        context: UIViewController,
        url: URL,
        _ body: B
    ) async throws -> R
}
