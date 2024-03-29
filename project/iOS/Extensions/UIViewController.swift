//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

extension UIViewController {
    struct ErrorPresentingOptions: OptionSet {
        // MARK: Lifecycle

        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        // MARK: Internal

        static let skipIfCancelled = ErrorPresentingOptions(rawValue: 1 << 0)

        static let `default`: ErrorPresentingOptions = [.skipIfCancelled]

        var rawValue: Int
    }

    func present(
        _ errorToPresent: Error,
        options: ErrorPresentingOptions = .default,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        if options.contains(.skipIfCancelled) {
            if errorToPresent is CancellationError {
                return
            }
            if let errorToPresent = errorToPresent as? ApplicationError,
               errorToPresent == .userCancelled
            {
                return
            }
        }

        var actions: [AlertViewController.Action] = []

        switch errorToPresent {
        case is PermissionError:
            actions.append(.settings)
            actions.append(.cancel)
        default:
            actions.append(.done)
        }

        let viewController = AlertViewController(
            image: .image(.jus_error42, tintColor: .jus_letter_red),
            title: ":(",
            message: errorToPresent.localizedDescription,
            actions: actions
        )

        topmostPresentedViewController.present(
            viewController,
            animated: animated,
            completion: completion
        )
    }

    func presentUnderDevelopment(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let viewController = AlertViewController(
            image: .image(.jus_development42, tintColor: .jus_letter_purple),
            title: "UnderDevelopmentPromptTitle".asLocalizedKey,
            message: "UnderDevelopmentPromptMessage".asLocalizedKey,
            actions: [.ok]
        )

        topmostPresentedViewController.present(
            viewController,
            animated: animated,
            completion: completion
        )
    }

    enum URLPresentationOptions {
        case `default`
        case internalBrowser
        case web3
    }

    func hide(
        animated: Bool,
        popIfAvailable: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        if let navigationController = navigationController {
            if navigationController.viewControllers.first == self || !popIfAvailable {
                navigationController.dismiss(animated: animated, completion: completion)
            } else {
                navigationController.popViewController(animated: animated)
                completion?()
            }
        } else {
            dismiss(animated: animated, completion: completion)
        }
    }

    func open(
        url: URL?,
        options: URLPresentationOptions = .default
    ) {
        guard let url = url
        else {
            return
        }

        switch options {
        case .default:
            UIApplication.shared.open(url)
        case .internalBrowser:
            let safariViewController = SafariViewController(initial: .url(value: url))
            jus_present(safariViewController, animated: true)
        case .web3:
            let web3ViewController = Web3ViewController(initial: .url(value: url))
            jus_present(web3ViewController, animated: true)
        }
    }
}
