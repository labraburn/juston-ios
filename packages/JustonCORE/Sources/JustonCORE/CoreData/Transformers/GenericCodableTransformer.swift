//
//  Created by Anton Spivak
//

import CoreData
import Foundation

internal class GenericCodableTransformer<T: Codable>: NSSecureUnarchiveFromDataTransformer {
    // MARK: Internal

    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSData.self]
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data,
              let result = try? decoder.decode(T.self, from: data)
        else {
            return AccountAppearance.default
        }

        return result
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let encodable = value as? T,
              let value = try? encoder.encode(encodable)
        else {
            fatalError(
                "Wrong data type: value must be a NSArray object; received \(type(of: value))"
            )
        }
        return value
    }

    // MARK: Private

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
}
