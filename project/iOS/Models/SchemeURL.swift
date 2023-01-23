//
//  Created by Anton Spivak
//

import Foundation
import SwiftyTON

// MARK: - SchemeURL

enum SchemeURL {
    case transfer(scheme: Scheme, configuration: TransferConfiguration)

    // MARK: Lifecycle

    init?(
        _ value: String
    ) {
        guard let url = URL(string: value)
        else {
            return nil
        }

        self.init(url)
    }

    init?(
        _ value: URL
    ) {
        guard let components = URLComponents(
            url: value,
            resolvingAgainstBaseURL: false
        )
        else {
            return nil
        }

        guard let scheme = Scheme(rawValue: components.scheme ?? "")
        else {
            return nil
        }

        switch components.host {
        case "transfer":
            break
        default:
            return nil
        }

        let lastPathComponent = (components.path as NSString).lastPathComponent
        guard let destinationAddress = ConcreteAddress(string: lastPathComponent)
        else {
            return nil
        }

        self = .transfer(
            scheme: scheme,
            configuration: TransferConfiguration(
                destination: DisplayableAddress(rawValue: destinationAddress),
                queryItems: components.queryItems
            )
        )
    }

    // MARK: Internal

    enum Scheme: String {
        case ton
        case juston
        case pay = "juston-pay"

        // MARK: Internal

        var isEditableParameters: Bool {
            switch self {
            case .pay:
                return false
            case .juston, .ton:
                return true
            }
        }
    }

    var url: URL {
        switch self {
        case let .transfer(scheme, configuration):
            let path = configuration.destination.displayName
            guard let url = URLComponents.url(
                "\(scheme.rawValue)://transfer/\(path)",
                queryItems: configuration.queryItems
            )
            else {
                fatalError("Can't create URLComponents from \(self)")
            }

            return url
        }
    }
}

private extension URLComponents {
    static func url(
        _ string: String,
        queryItems: [URLQueryItem]
    ) -> URL? {
        guard var components = URLComponents(string: string)
        else {
            return nil
        }

        components.queryItems = queryItems
        return components.url
    }
}

private extension TransferConfiguration {
    init(
        destination: DisplayableAddress,
        queryItems: [URLQueryItem]?
    ) {
        var amount: Currency?
        var message: String?

        var payload: Data?
        var initial: Data?

        queryItems?.forEach({
            guard let value = $0.value
            else {
                return
            }

            switch $0.name.lowercased() {
            case "amount":
                guard let int = Int64(value)
                else {
                    break
                }

                amount = Currency(value: int)
            case "message", "text":
                message = value
            case "bin":
                payload = Data(base64Encoded: value.base64URLUnescaped())
            case "init":
                initial = Data(base64Encoded: value.base64URLUnescaped())
            default:
                break
            }
        })

        self.destination = destination
        self.amount = amount
        self.message = message
        self.payload = payload
        self.initial = initial
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        items.append("amount", value: amount?.value)
        items.append("text", value: message)
        items.append("bin", value: payload?.base64EncodedString(options: []).base64URLEscaped())
        items.append("init", value: initial?.base64EncodedString(options: []).base64URLEscaped())
        return items
    }
}

private extension Array where Element == URLQueryItem {
    mutating func append(_ name: String, value: Any?) {
        guard let value = value
        else {
            return
        }

        append(URLQueryItem(name: name, value: "\(value)"))
    }
}
