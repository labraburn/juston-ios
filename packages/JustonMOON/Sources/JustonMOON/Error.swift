//
//  Created by Anton Spivak
//

import Foundation

// MARK: - Error

public enum Error {
    case url(URLError)
    case http(HTTPURLResponse?)
    case decoding(Swift.Error)

    case wrongContentType
    case unsupportedContentType
}

// MARK: Swift.Error

extension Error: Swift.Error {}
