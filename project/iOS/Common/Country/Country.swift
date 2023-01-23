//
//  Created by Anton Spivak
//

import CoreTelephony
import Foundation
import StoreKit

struct Country {
    // MARK: Lifecycle

    private init() {
        self._telephone = Country.countryWithTelephonyNetworkInfo()
        self._store = Country.countryWithSKPaymentQueue()
    }

    // MARK: Internal

    enum ISO: String {
        case ru

        // MARK: Lifecycle

        init?(rawValue: String) {
            switch rawValue {
            case "ru", "RU", "ru-RU", "rus", "RUS":
                self = .ru
            default:
                return nil
            }
        }
    }

    static let shared = Country()

    func probably(
        in iso: ISO
    ) -> Bool {
        _telephone.contains(iso) || _store.contains(iso)
    }

    // MARK: Private

    private let _telephone: [ISO]
    private let _store: [ISO]

    private static func countryWithTelephonyNetworkInfo() -> [ISO] {
        let networkInfo = CTTelephonyNetworkInfo()
        let providers = networkInfo.serviceSubscriberCellularProviders
        var countries: [ISO] = []

        providers?.forEach({ _, carrier in
            guard let isoCountryCode = carrier.isoCountryCode,
                  let iso = ISO(rawValue: isoCountryCode)
            else {
                return
            }

            countries.append(iso)
        })

        return countries
    }

    private static func countryWithSKPaymentQueue() -> [ISO] {
        guard let code = SKPaymentQueue.default().storefront?.countryCode,
              let iso = ISO(rawValue: code)
        else {
            return []
        }

        return [iso]
    }
}
