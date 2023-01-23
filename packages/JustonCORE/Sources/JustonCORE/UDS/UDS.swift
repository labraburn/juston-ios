//
//  Created by Anton Spivak
//

import Foundation

// MARK: - UDS

public final class UDS {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public enum Kind {
        case target
        case group(identifier: UserDefaultsAccessGroup = .shared)
    }

    public struct Key: RawRepresentable {
        // MARK: Lifecycle

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        // MARK: Public

        public var rawValue: String
    }

    public static let shared: UDS = .init()

    public func set(_ value: Any?, forKey key: Key, in kind: Kind = .group()) {
        kind.userDefaults.set(value, forKey: key.rawValue)
    }

    public func value<T>(forKey key: Key, in kind: Kind = .group()) -> T? {
        kind.userDefaults.object(forKey: key.rawValue) as? T
    }

    public func value<T>(forKey key: Key, in kind: Kind = .group(), fallback: T) -> T {
        guard let value = kind.userDefaults.object(forKey: key.rawValue) as? T
        else {
            return fallback
        }
        return value
    }
}

private extension UDS.Kind {
    var userDefaults: UserDefaults {
        switch self {
        case .target:
            return .standard
        case let .group(identifier):
            guard let userDefaults = UserDefaults(suiteName: identifier.label)
            else {
                #if DEBUG
                fatalError("Can't initialize UserDefaults for group name: \(identifier.label)")
                #else
                return .standard
                #endif
            }

            return userDefaults
        }
    }
}
