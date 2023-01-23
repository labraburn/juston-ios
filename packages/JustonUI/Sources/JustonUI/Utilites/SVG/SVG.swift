//
//  Created by Anton Spivak
//

import UIKit

// MARK: - SVG

public final class SVG {
    // MARK: Lifecycle

    public init(string: String) throws {
        self.string = string
        self.elements = try SVG.parse(string: string)
    }

    // MARK: Public

    public enum Element {
        case command(value: String)
        case number(value: Double)
    }

    public enum ParsingError: Error {
        case parseNumber
    }

    public enum ConvertingError: Error {
        case pointCount
        case unsupportedCommand
    }

    public let string: String
    public let elements: [Element]

    // MARK: Private

    private static func parse(string: String) throws -> [Element] {
        var result: [Element] = []

        var temp: [String] = []
        let reset = { () throws in
            guard !temp.isEmpty
            else {
                return
            }

            guard let number = Double(temp.joined())
            else {
                throw ParsingError.parseNumber
            }

            result.append(.number(value: number))
            temp.removeAll()
        }

        var set = CharacterSet.letters
        guard let scalar = "e".unicodeScalars.first
        else {
            fatalError("Can't exclude 'e' from CharacterSet")
        }
        set.remove(scalar)

        try string.forEach { character in
            if character == " " || character == "," {
                try reset()
            } else if character.set().isSubset(of: set) {
                try reset()
                result.append(.command(value: String(character)))
            } else {
                temp.append(String(character))
            }
        }

        return result
    }
}

private extension Character {
    func set() -> CharacterSet {
        CharacterSet(charactersIn: String(self))
    }
}

private extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
