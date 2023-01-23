//
//  Created by Anton Spivak
//

// https://github.com/Geri-Borbas/iOS.Blog.Declarative_UIKit/blob/main/Declarative_UIKit/Extensions/Withable.swift

import Foundation

// MARK: - ObjectWithable

public protocol ObjectWithable: AnyObject {
    associatedtype T

    /// Provides a closure to configure instances inline.
    /// - Parameter closure: A closure `self` as the argument.
    /// - Returns: Simply returns the instance after called the `closure`.
    @discardableResult
    func with(_ closure: (_ instance: T) -> Void) -> T
}

public extension ObjectWithable {
    @discardableResult
    func with(_ closure: (_ instance: Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

// MARK: - NSObject + ObjectWithable

extension NSObject: ObjectWithable {}
