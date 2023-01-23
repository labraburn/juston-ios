//
//  Created by Anton Spivak
//

import Foundation

struct WKWeb3Error: LocalizedError, Encodable {
    // MARK: Lifecycle

    init(
        _ code: Code
    ) {
        self.code = code
    }

    // MARK: Internal

    enum Code: Int {
        case `internal` = 0
        case userRejectedRequest = 4001
        case unauthorized = 4100
        case unsupportedMethod = 4200
        case disconnected = 4900
        case chainDisconnected = 4901

        // MARK: Fileprivate

        fileprivate var message: String {
            switch self {
            case .userRejectedRequest:
                return "The user rejected the request"
            case .unauthorized:
                return "The requested method and/or account has not been authorized by the user"
            case .unsupportedMethod:
                return "The Provider does not support the requested method"
            case .disconnected:
                return "The Provider is disconnected from all chains"
            case .chainDisconnected:
                return "The Provider is not connected to the requested chain"
            case .internal:
                return "The internal system error"
            }
        }
    }

    let code: Code

    var errorDescription: String? {
        code.message
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code.rawValue, forKey: .code)
        try container.encode(code.message, forKey: .message)
    }

    // MARK: Private

    private enum CodingKeys: CodingKey {
        case code
        case message
    }
}
