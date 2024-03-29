//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

// MARK: - ExploreViewController

class ExploreViewController: TripleViewController {
    // MARK: Lifecycle

    init() {
        super.init((
            ExploreSafari3ViewController(),
            AccountStackViewController(),
            TransactionsViewController()
        ))

        delegate = self
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .jus_backgroundPrimary

        safari3ViewController.attach(accountStackViewController.browserNavigationView)

        accountStackViewController.delegate = self
        account = accountStackViewController.selectedCard?.account
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOnboardingViewControllerIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !isInitialized
        else {
            return
        }

        isInitialized = true
        update(
            presentation: .middle,
            animated: false
        )
    }

    // MARK: API

    func showTransferViewControllerIfAvailable(
        with configuration: TransferConfiguration?,
        isEditable: Bool
    ) {
        guard let account = accountStackViewController.selectedCard?.account
        else {
            return
        }

        let viewController = TransferNavigationController(
            initialConfiguration: .init(
                fromAccount: account,
                isEditable: isEditable,
                configuration: configuration
            )
        )

        topmostPresentedViewController.jus_present(
            viewController,
            animated: true
        )
    }

    // MARK: Fileprivate

    fileprivate func showOnboardingViewControllerIfNeeded() {
        let isCardsEmpty = accountStackViewController.cards.isEmpty
        Task {
            let initialConfiguration = await OnboardingNavigationController.InitialConfiguration
                .dependsUserDefaults()

            /// cards > 1 means not only `[.account]`
            guard initialConfiguration.screens.count > 1 || isCardsEmpty
            else {
                return
            }

            let navigationController = OnboardingNavigationController(
                initialConfiguration: initialConfiguration
            )

            jus_present(navigationController, animated: true, completion: nil)
        }
    }

    // MARK: Private

    private let synchronizationLoop = SynchronizationLoop()
    private var isInitialized: Bool = false

    private var account: PersistenceAccount? {
        didSet {
            isGesturesEnabled = account != nil
            if account == nil {
                update(
                    presentation: .middle,
                    animated: viewIfLoaded?.window != nil
                )
            }

            safari3ViewController.account = account
            transactionsViewController.account = account

            if let account = account {
                synchronizationLoop.use(address: account.selectedContract.address)
            } else {
                synchronizationLoop.use(address: nil)
            }
        }
    }

    private var safari3ViewController: Safari3ViewController {
        viewControlles.0 as! Safari3ViewController
    }

    private var accountStackViewController: AccountStackViewController {
        viewControlles.1 as! AccountStackViewController
    }

    private var transactionsViewController: TransactionsViewController {
        viewControlles.2 as! TransactionsViewController
    }
}

// MARK: AccountStackViewControllerDelegate

extension ExploreViewController: AccountStackViewControllerDelegate {
    func cardStackViewController(
        _ viewController: CardStackViewController,
        didChangeSelectedModel model: CardStackCard?
    ) {
        account = model?.account
    }

    func cardStackViewController(
        _ viewController: CardStackViewController,
        didClickAtModel model: CardStackCard?
    ) {
        switch presentation {
        case .bottom, .top:
            update(presentation: .middle, animated: true)
        case .middle:
            break
        }
    }
}

// MARK: TripleViewControllerDelegate

extension ExploreViewController: TripleViewControllerDelegate {
    func tripleViewController(
        _ viewController: TripleViewController,
        didChangeOffset offset: CGPoint
    ) {}

    func tripleViewController(
        _ viewController: TripleViewController,
        didChangePresentation presentation: TriplePresentation
    ) {
        accountStackViewController.triplePresentation = presentation
    }
}
