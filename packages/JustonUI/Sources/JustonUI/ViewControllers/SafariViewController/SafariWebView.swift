//
//  Created by Anton Spivak
//

import UIKit
import WebKit

final class SafariWebView: WKWebView {
    // MARK: Lifecycle

    override init(
        frame: CGRect,
        configuration: WKWebViewConfiguration
    ) {
        super.init(
            frame: frame,
            configuration: configuration
        )

        // To avoid flash on start

        backgroundColor = .jus_backgroundPrimary
        isOpaque = false

        loadHTMLString(
            "<html style=\"background-color:#10080E\"></html>",
            baseURL: nil
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.isOpaque = true
        })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var additionalSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.contentInset = additionalSafeAreaInsets

            safeAreaInsetsDidChange()
        }
    }

    override var safeAreaInsets: UIEdgeInsets {
        additionalSafeAreaInsets
    }

    @objc(_computedContentInset) // css.env(safe-area-insets)
    func _computedContentInset() -> UIEdgeInsets {
        additionalSafeAreaInsets
    }

    @objc(_computedObscuredInset) // css.env(safe-area-insets)
    func _computedObscuredInset() -> UIEdgeInsets {
        additionalSafeAreaInsets
    }

    @objc(_scrollViewSystemContentInset) // css.env(safe-area-insets)
    func _scrollViewSystemContentInset() -> UIEdgeInsets {
        additionalSafeAreaInsets
    }
}
