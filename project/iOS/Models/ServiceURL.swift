//
//  Created by Anton Spivak
//

import Foundation

extension URL {
    static let juston = URL(string: "https://juston.io")!

    static let privacyPolicy = URL(string: "https://juston.io/privacy")!
    static let termsOfUse = URL(string: "https://juston.io/terms")!

    static let veneraPrivacyPolicy = URL(string: "https://venera.exchange/docs/Policy.pdf")!
    static let veneraTermsOfUse = URL(string: "https://venera.exchange/docs/Agreement.pdf")!

    static let appStore = URL(string: "itms-apps://apple.com/app/id1629214799")!

    static let telegramChat = URL(string: "https://t.me/juston_ru_chat")!
    static let telegramChannel = URL(string: "https://t.me/juston_ru")!

    static let blank = URL(string: "about:blank")!

    static func searchURL(withQuery text: String) -> URL? {
        guard var components = URLComponents(string: "https://www.google.com/search")
        else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: text),
        ]

        return components.url
    }
}
