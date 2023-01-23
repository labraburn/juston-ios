//
//  Created by Anton Spivak
//

import Foundation
import WebKit

// MARK: - WKWeb3EventDispatcher

protocol WKWeb3EventDispatcher: AnyObject {
    var presentationContext: UIViewController? { get }
    var url: URL? { get }

    func dispatch(
        name: String,
        detail: String
    ) async throws
}

// MARK: - WKWebView + WKWeb3EventDispatcher

extension WKWebView: WKWeb3EventDispatcher {
    var presentationContext: UIViewController? {
        nil
    }

    func dispatch(
        name: String,
        detail: String
    ) async throws {
        try await evaluateJavaScript(
            "window.dispatchEvent(new CustomEvent(\"\(name)\", { \"detail\": \(detail) }));"
        )
    }
}
