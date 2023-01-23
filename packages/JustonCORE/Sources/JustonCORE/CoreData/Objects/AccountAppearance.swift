//
//  Created by Anton Spivak
//

import Foundation
import UIKit

// MARK: - AccountAppearance

public struct AccountAppearance {
    // MARK: Lifecycle

    public init(
        kind: Kind,
        tintColor: Int,
        controlsForegroundColor: Int,
        controlsBackgroundColor: Int
    ) {
        self.kind = kind
        self.tintColor = tintColor
        self.controlsForegroundColor = controlsForegroundColor
        self.controlsBackgroundColor = controlsBackgroundColor
    }

    // MARK: Public

    public enum Kind {
        case glass(gradient0Color: Int, gradient1Color: Int)
        case gradientImage(imageData: Data, strokeColor: Int)
    }

    public static let `default` = AccountAppearance(
        kind: .glass(gradient0Color: 0xEB03FFFF, gradient1Color: 0x23FFD7A5),
        tintColor: 0xFFFFFFFF,
        controlsForegroundColor: 0xFFFFFFFF,
        controlsBackgroundColor: 0x1D3738FF
    )

    public let kind: Kind
    public let tintColor: Int
    public let controlsForegroundColor: Int
    public let controlsBackgroundColor: Int
}

// MARK: Codable

extension AccountAppearance: Codable {
    public enum CodingKeys: CodingKey {
        case kind
        case tintColor
        case controlsForegroundColor
        case controlsBackgroundColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.kind = container.decode(
            Kind.self,
            forKey: .kind,
            fallback: AccountAppearance.default.kind
        )

        self.tintColor = container.decode(
            Int.self,
            forKey: .tintColor,
            fallback: AccountAppearance.default.tintColor
        )

        self.controlsForegroundColor = container.decode(
            Int.self,
            forKey: .controlsForegroundColor,
            fallback: AccountAppearance.default.controlsForegroundColor
        )

        self.controlsBackgroundColor = container.decode(
            Int.self,
            forKey: .controlsBackgroundColor,
            fallback: AccountAppearance.default.controlsBackgroundColor
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kind, forKey: .kind)
        try container.encode(tintColor, forKey: .tintColor)
        try container.encode(controlsForegroundColor, forKey: .controlsForegroundColor)
        try container.encode(controlsBackgroundColor, forKey: .controlsBackgroundColor)
    }
}

// MARK: - AccountAppearance.Kind + Codable

extension AccountAppearance.Kind: Codable {
    public enum CodingKeys: CodingKey {
        case kase

        case gradient0Color
        case gradient1Color

        case imageData
        case strokeColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let kase = try container.decode(String.self, forKey: .kase)
        switch kase {
        case "glass":
            self = .glass(
                gradient0Color: container.decode(
                    Int.self,
                    forKey: .gradient0Color,
                    fallback: 0xEB03FFFF
                ),
                gradient1Color: container.decode(
                    Int.self,
                    forKey: .gradient1Color,
                    fallback: 0x23FFD7A5
                )
            )
        case "gradientImage":
            self = .gradientImage(
                imageData: container.decode(Data.self, forKey: .imageData, fallback: Data()),
                strokeColor: container.decode(Int.self, forKey: .strokeColor, fallback: 0xFEF6FF0A)
            )
        default:
            self = .glass(
                gradient0Color: container.decode(
                    Int.self,
                    forKey: .gradient0Color,
                    fallback: 0xEB03FFFF
                ),
                gradient1Color: container.decode(
                    Int.self,
                    forKey: .gradient1Color,
                    fallback: 0x23FFD7A5
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .glass(gradient0Color, gradient1Color):
            try container.encode("glass", forKey: .kase)
            try container.encode(gradient0Color, forKey: .gradient0Color)
            try container.encode(gradient1Color, forKey: .gradient1Color)
        case let .gradientImage(imageData, strokeColor):
            try container.encode("gradientImage", forKey: .kase)
            try container.encode(imageData, forKey: .imageData)
            try container.encode(strokeColor, forKey: .strokeColor)
        }
    }
}

// MARK: - AccountAppearance.Kind + Hashable

extension AccountAppearance.Kind: Hashable {}

// MARK: - AccountAppearance + Hashable

extension AccountAppearance: Hashable {}
