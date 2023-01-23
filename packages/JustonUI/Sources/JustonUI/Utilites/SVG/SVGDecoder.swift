//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

// MARK: - SVGDecoderError

public enum SVGDecoderError {
    case undefined
}

// MARK: - SVGDecoder

public struct SVGDecoder {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public func decode(from fileURL: URL) throws -> UIImage {
        guard let image = try decoder.decodeImage(withContentsOf: fileURL)
        else {
            throw SVGDecoderError.undefined
        }

        return image
    }

    public func decode(from data: Data) throws -> UIImage {
        guard let image = try decoder.decodeImage(with: data)
        else {
            throw SVGDecoderError.undefined
        }

        return image
    }

    // MARK: Private

    private let decoder = SUISVGDecoder()
}

// MARK: - SVGDecoderError + LocalizedError

extension SVGDecoderError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .undefined:
            return "Can't decode image from SVG data"
        }
    }
}
