//
//  Created by Anton Spivak
//

import UIKit

// MARK: - SubviewsBuilder

@resultBuilder
public enum SubviewsBuilder {
    public static func buildBlock() -> [UIView] {
        []
    }

    public static func buildBlock(_ components: UIView...) -> [UIView] {
        components
    }

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[UIView]]) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildIf(_ content: UIView?) -> [UIView] {
        guard let content = content else {
            return []
        }

        return [content]
    }

    public static func buildEither(first: UIView) -> [UIView] {
        [first]
    }

    public static func buildEither(second: UIView) -> [UIView] {
        [second]
    }
}

// MARK: - AttributedStringGroup

public protocol AttributedStringGroup {
    var strings: [NSAttributedString] { get }
}

// MARK: - NSAttributedString + AttributedStringGroup

extension NSAttributedString: AttributedStringGroup {
    public var strings: [NSAttributedString] { [self] }
}

// MARK: - Array + AttributedStringGroup

extension Array: AttributedStringGroup where Element == NSAttributedString {
    public var strings: [NSAttributedString] { self }
}

// MARK: - AttributedStringBuilder

@resultBuilder
public enum AttributedStringBuilder {
    public static func buildBlock() -> [NSAttributedString] {
        []
    }

    public static func buildBlock(_ components: AttributedStringGroup...) -> [NSAttributedString] {
        components.flatMap(\.strings)
    }

    public static func buildArray(_ components: [AttributedStringGroup]) -> [NSAttributedString] {
        components.flatMap(\.strings)
    }

    public static func buildIf(_ content: AttributedStringGroup?) -> [NSAttributedString] {
        content?.strings ?? []
    }

    public static func buildOptional(_ components: [AttributedStringGroup]?)
        -> [NSAttributedString]
    {
        components?.flatMap(\.strings) ?? []
    }

    public static func buildEither(first: AttributedStringGroup) -> [NSAttributedString] {
        first.strings
    }

    public static func buildEither(second: AttributedStringGroup) -> [NSAttributedString] {
        second.strings
    }
}

// MARK: - ConstraintsGroup

///
/// ConstraintsBuilder
///

public protocol ConstraintsGroup {
    var constraints: [NSLayoutConstraint] { get }
}

// MARK: - NSLayoutConstraint + ConstraintsGroup

extension NSLayoutConstraint: ConstraintsGroup {
    public var constraints: [NSLayoutConstraint] { [self] }
}

// MARK: - Array + ConstraintsGroup

extension Array: ConstraintsGroup where Element == NSLayoutConstraint {
    public var constraints: [NSLayoutConstraint] { self }
}

// MARK: - ConstraintsBuilder

@resultBuilder
public enum ConstraintsBuilder {
    public static func buildBlock() -> [NSLayoutConstraint] {
        []
    }

    public static func buildBlock(_ components: ConstraintsGroup...) -> [NSLayoutConstraint] {
        components.flatMap(\.constraints)
    }

    public static func buildArray(_ components: [ConstraintsGroup]) -> [NSLayoutConstraint] {
        components.flatMap(\.constraints)
    }

    public static func buildIf(_ content: ConstraintsGroup?) -> [NSLayoutConstraint] {
        content?.constraints ?? []
    }

    public static func buildOptional(_ components: [ConstraintsGroup]?) -> [NSLayoutConstraint] {
        components?.flatMap(\.constraints) ?? []
    }

    public static func buildEither(first: ConstraintsGroup) -> [NSLayoutConstraint] {
        first.constraints
    }

    public static func buildEither(second: ConstraintsGroup) -> [NSLayoutConstraint] {
        second.constraints
    }
}
