//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import MessageUI
import UIKit

// MARK: - DeveloperViewController

class DeveloperViewController: C42CollectionViewController {
    init(
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        let configurationButtonTitle = { () -> String in
            switch SwiftyTON.configuration.network {
            case .main:
                return "DeveloperSwitchTestnetButton".asLocalizedKey
            case .test:
                return "DeveloperSwitchMainnetButton".asLocalizedKey
            }
        }()

        super.init(
            title: "DeveloperTitle".asLocalizedKey,
            sections: [
                // Description
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .label(
                            text: "DeveloperDescription".asLocalizedKey,
                            kind: .headline
                        ),
                    ]
                ),
                // Debug
                .init(
                    section: .init(
                        kind: .simple,
                        header: .none
                    ),
                    items: [
                        .synchronousButton(
                            title: "DeveloperClearAllDataButton".asLocalizedKey,
                            kind: .secondary,
                            action: { viewController in
                                (viewController as? DeveloperViewController)?
                                    .presentRemoveAllAction()
                            }
                        ),
                        .synchronousButton(
                            title: configurationButtonTitle,
                            kind: .secondary,
                            action: { viewController in
                                switch SwiftyTON.configuration.network {
                                case .main:
                                    SwiftyTON.change(configuration: .test)
                                case .test:
                                    SwiftyTON.change(configuration: .main)
                                }

                                viewController.hide(animated: true)
                            }
                        ),
                    ]
                ),
                // Application version
                .init(
                    section: .init(
                        kind: .simple,
                        header: .applicationVersion
                    ),
                    items: []
                ),
            ],
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
}

private extension DeveloperViewController {
    func presentRemoveAllAction() {
        let action = { @PersistenceWritableActor in
            let context = PersistenceWritableActor.shared.managedObjectContext
            let request = PersistenceAccount.fetchRequestSortingLastUsage()
            let result = try context.fetch(request)

            try result.forEach({
                try $0.delete()
            })

            let parole = SecureParole()
            try await parole.removeKey()

            UDS.isWelcomeScreenViewed = false
            UDS.isAgreementsAccepted = false

            fatalError("42")
        }

        let alertViewController = AlertViewController(
            image: .image(.jus_warning42, tintColor: .jus_letter_red),
            title: "CommonAttention".asLocalizedKey,
            message: "CommonUndoneAction".asLocalizedKey,
            actions: [
                .init(
                    title: "CommonYes".asLocalizedKey,
                    block: { viewController in
                        Task { try await action() }
                    },
                    style: .destructive
                ),
                .cancel,
            ]
        )

        jus_present(alertViewController, animated: true)
    }
}
