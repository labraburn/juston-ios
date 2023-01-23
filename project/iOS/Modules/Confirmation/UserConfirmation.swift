//
//  Created by Anton Spivak
//

import SwiftyTON
import UIKit

// MARK: - UserConfirmation

actor UserConfirmation {
    // MARK: Lifecycle

    init(
        _ action: ConfirmationAction,
        presentationContext viewController: UIViewController
    ) {
        self.confirmationAction = action
        self.presentationContext = viewController
    }

    // MARK: Internal

    enum ConfirmationAction {
        case sign(host: String)
        case transaction(host: String, destination: DisplayableAddress, value: Currency)
        case largeTransactionUnbouncableAddress
    }

    let confirmationAction: ConfirmationAction
    let presentationContext: UIViewController

    func confirm() async throws {
        let task = Task<Void, Error> {
            try await withCheckedThrowingContinuation({ continuation in
                self.continuation = continuation
            })
        }

        let action = confirmationAction

        await MainActor.run(body: {
            let viewController = action.viewController(with: { [weak self] allowed in
                Task {
                    if allowed {
                        await self?.continuation?.resume(returning: ())
                    } else {
                        await self?.continuation?
                            .resume(throwing: WKWeb3Error(.userRejectedRequest))
                    }
                }
            })

            presentationContext.jus_present(
                viewController,
                animated: true
            )
        })

        return try await task.value
    }

    // MARK: Private

    private var continuation: CheckedContinuation<Void, Error>?
}

private extension UserConfirmation.ConfirmationAction {
    func viewController(
        with completionBlock: @escaping (_ allowed: Bool) -> Void
    ) -> UIViewController {
        let image: AlertViewControllerImage
        let message: String

        switch self {
        case let .sign(host):
            image = .image(.jus_warning42, tintColor: .jus_letter_yellow)
            message = String(
                format: "UserConfirmationSignMessage".asLocalizedKey,
                host.uppercased()
            )
        case let .transaction(host, destination, value):
            image = .image(.jus_warning42, tintColor: .jus_letter_red)
            message = String(
                format: "UserConfirmationTransactionMessage".asLocalizedKey,
                host.uppercased(),
                value.string(with: .maximum9),
                destination.displayName
            )
        case .largeTransactionUnbouncableAddress:
            image = .image(.jus_warning42, tintColor: .jus_letter_yellow)
            message = "UserConfirmationLargeAmountUnbouncableAddress".asLocalizedKey
        }

        return ConfirmationViewController(
            image: image,
            message: message,
            completion: { confirmed in
                completionBlock(confirmed)
            }
        )
    }
}
