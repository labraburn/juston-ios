//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

// MARK: - AccountStackViewControllerDelegate

protocol AccountStackViewControllerDelegate: CardStackViewControllerDelegate {}

// MARK: - AccountStackViewController

class AccountStackViewController: UIViewController {
    // MARK: Internal

    weak var delegate: AccountStackViewControllerDelegate? {
        get { cardStackViewController.delegate as? AccountStackViewControllerDelegate }
        set { cardStackViewController.delegate = newValue }
    }

    var selectedCard: CardStackCard? {
        cardStackViewController.selectedCard
    }

    var cards: [CardStackCard] {
        cardStackViewController.cards
    }

    var browserNavigationView: AccountStackBrowserNavigationView {
        accountStackView.browserNavigationView
    }

    var triplePresentation: TriplePresentation {
        get { accountStackView.triplePresentation }
        set {
            guard accountStackView.triplePresentation != newValue
            else {
                return
            }

            accountStackView.triplePresentation = newValue

            endTriplePresentationAnimations()
            startTriplePresentationAnimations({
                self.accountStackView.layoutIfNeeded()
            })
        }
    }

    override func loadView() {
        let accountStackView = AccountStackView()
        view = accountStackView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(cardStackViewController)
        accountStackView.cardStackView = cardStackViewController.cardStackView
        cardStackViewController.didMove(toParent: self)

        accountStackView.scanQRButton.addTarget(
            self,
            action: #selector(scanQRButtonDidClick(_:)),
            for: .touchUpInside
        )
        accountStackView.topLogotypeView.addTarget(
            self,
            action: #selector(topLogotypeControlDidClick(_:)),
            for: .touchUpInside
        )
        accountStackView.addAccountButton.addTarget(
            self,
            action: #selector(addAccountButtonDidClick(_:)),
            for: .touchUpInside
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        accountStackView.perfromApperingAnimation()
    }

    // MARK: Private

    private let cardStackViewController = CardStackViewController()
    private var animator: UIViewPropertyAnimator?

    private var accountStackView: AccountStackView {
        view as! AccountStackView
    }

    private func startTriplePresentationAnimations(
        _ block: @escaping () -> Void
    ) {
        animator = UIViewPropertyAnimator(
            duration: 0.21,
            timingParameters: UISpringTimingParameters(
                damping: 1,
                response: 0.36
            )
        )

        animator?.addAnimations(block)
        animator?.startAnimation()
    }

    private func endTriplePresentationAnimations() {
        animator?.stopAnimation(true)
        animator?.finishAnimation(at: .current)
        animator = nil
    }

    // MARK: Actions

    @objc
    private func addAccountButtonDidClick(
        _ sender: UIButton
    ) {
        // This is simple and low-weight and fast task
        Task {
            let navigationController = OnboardingNavigationController(
                initialConfiguration: await .dependsUserDefaults()
            )

            jus_present(navigationController, animated: true, completion: nil)
        }
    }

    @objc
    private func topLogotypeControlDidClick(
        _ sender: UIControl
    ) {
        let settingsNavigationController = C42NavigationController(
            rootViewController: SettingsViewController()
        )

        jus_present(settingsNavigationController, animated: true)
    }

    @objc
    private func scanQRButtonDidClick(
        _ sender: UIButton
    ) {
        let qrViewController = CameraViewController()
        qrViewController.delegate = self

        let navigationController = NavigationController(rootViewController: qrViewController)
        jus_present(navigationController, animated: true, completion: nil)
    }
}

// MARK: CameraViewControllerDelegate

extension AccountStackViewController: CameraViewControllerDelegate {
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeSchemeURL schemeURL: SchemeURL
    ) {
        let navigationController = viewController.navigationController

        switch schemeURL {
        case let .transfer(scheme, configuration):
            guard let account = cardStackViewController.selectedCard?.account
            else {
                return
            }

            let viewController = TransferDetailsViewController(
                initialConfiguration: .init(
                    fromAccount: account,
                    isEditable: scheme.isEditableParameters,
                    configuration: configuration
                )
            )

            navigationController?.pushViewController(
                viewController,
                animated: true
            )
        }
    }
}

// MARK: TripleMiddleViewController

extension AccountStackViewController: TripleMiddleViewController {
    func compactHeight(
        for positioning: TripleCompactPositioning
    ) -> CGFloat {
        switch positioning {
        case .top:
            return AccountStackView.compactTopHeight
        case .bottom:
            return AccountStackView.compactBottomHeight
        }
    }
}
