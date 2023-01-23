//
//  Created by Anton Spivak
//

import Foundation

public extension String {
    var url: URL? {
        let string = trimmingCharacters(in: .whitespaces)
        if let url = NSDataDetector.ordinaryURL(from: string) {
            return url
        } else if let url = NSRegularExpression.tonURL(from: string) {
            return url
        } else {
            return nil
        }
    }
}

private extension NSDataDetector {
    private static var detector: NSDataDetector {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        )
        else {
            fatalError("[JustonCORE]: Can't create NSDataDetector")
        }
        return detector
    }

    static func ordinaryURL(from string: String) -> URL? {
        let range = NSRange(location: 0, length: string.utf16.count)
        let match = Self.detector.firstMatch(
            in: string,
            options: [],
            range: range
        )

        if let match = match, match.range == range {
            if let url = URL(string: string),
               let host = url.host,
               host.isTONorADNL
            {
                var components = URLComponents(string: string)
                components?.scheme = "http"
                return components?.url
            } else if string.hasPrefix("http://") || string.hasPrefix("https://") {
                return URL(string: string)
            } else {
                return URL(string: "https://\(string)")
            }
        }

        return nil
    }
}

private extension NSRegularExpression {
    static var tonURLRegularExpression: NSRegularExpression? = {
        let pattern =
            "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let regularExpression = try? NSRegularExpression(pattern: pattern)
        return regularExpression
    }()

    static func tonURL(from string: String) -> URL? {
        let range = NSRange(location: 0, length: string.utf16.count)
        guard let tonURLRegularExpression = Self.tonURLRegularExpression
        else {
            return nil
        }

        let match = tonURLRegularExpression.firstMatch(
            in: string,
            options: [],
            range: range
        )

        let hasScheme = string.hasSuffix("http") || string.hasSuffix("https")
        let stringURL = hasScheme ? string : "http://\(string)"

        if let match = match, match.range == range,
           var components = URLComponents(string: stringURL),
           let host = components.host,
           host.isTONorADNL
        {
            components.scheme = "http"
            return components.url
        }

        return nil
    }
}

private extension String {
    var isTONorADNL: Bool {
        hasSuffix(".ton") || hasSuffix(".adnl")
    }
}
