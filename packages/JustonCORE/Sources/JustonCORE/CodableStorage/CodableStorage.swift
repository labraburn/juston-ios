//
//  Created by Anton Spivak
//

import Foundation

/// Default storages
public extension CodableStorage {
    static let target: CodableStorage = .init(
        directoryURL: FileManager.default.directoryURL(
            with: .target,
            with: .persistent,
            pathComponent: .codableStorage
        )
    )

    static let group: CodableStorage = .init(
        directoryURL: FileManager.default.directoryURL(
            with: .group(),
            with: .persistent,
            pathComponent: .codableStorage
        )
    )
}

// MARK: - CodableStorage

/// Storage that stores data unsecured in filesystem
public struct CodableStorage {
    // MARK: Lifecycle

    fileprivate init(directoryURL: URL) {
        self.url = directoryURL
    }

    // MARK: Public

    /// The key that will be used as filename
    public struct Key: RawRepresentable {
        // MARK: Lifecycle

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        // MARK: Public

        public var rawValue: String
    }

    public func save<T: Encodable>(value: T?, forKey key: Key) async throws {
        let queue = self.queue
        let url = self.url.appendingPathComponent(key.rawValue).appendingPathExtension("json")
        let fileManager = self.fileManager
        let encoder = self.encoder

        try await withCheckedThrowingContinuation(
            { (continuation: CheckedContinuation<Void, Error>) in
                queue.async(execute: {
                    do {
                        if let value = value {
                            let data = try encoder.encode(value)
                            try data.write(to: url)
                        } else {
                            try? fileManager.removeItem(at: url)
                        }
                        continuation.resume(returning: ())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                })
            }
        )
    }

    public func value<T: Decodable>(of type: T.Type, forKey key: Key) async throws -> T? {
        let queue = self.queue
        let url = self.url.appendingPathComponent(key.rawValue).appendingPathExtension("json")
        let decoder = self.decoder

        return try await withCheckedThrowingContinuation({ continuation in
            queue.async(execute: {
                do {
                    if let data = try? Data(contentsOf: url) {
                        let value = try decoder.decode(type, from: data)
                        continuation.resume(returning: value)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            })
        })
    }

    // MARK: Private

    private let queue = DispatchQueue(label: "com.juston.cs", qos: .userInitiated)

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let fileManager = FileManager.default
    private let url: URL
}

/// Simplified extension for getter/setter extensions
///
/// ```
/// extensinon CodableStorage.Methods {
///
///     func value() async throws -> [Value] {
///         return try await storage.value(Value.self for: .key)
///     }
/// }
///
/// try await CodableStorage.group.methods.value()
/// ```
extension CodableStorage {
    struct Methods {
        let storage: CodableStorage
    }

    var methods: Methods {
        Methods(storage: self)
    }
}
