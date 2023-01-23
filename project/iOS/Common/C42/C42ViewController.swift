//
//  Created by Anton Spivak
//

import JustonCORE
import UIKit

// MARK: - C42ViewController

@MainActor
protocol C42ViewController: UIViewController {
    var title: String? { get }

    var isModalInPresentation: Bool { get }
    var isBackActionAvailable: Bool { get }
    var isNavigationBarHidden: Bool { get }
}

// MARK: - C42ConcreteViewController

class C42ConcreteViewController: UIViewController, C42ViewController {
    // MARK: Lifecycle

    init(
        title: String,
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        self.isBackActionAvailable = isBackActionAvailable
        self.isNavigationBarHidden = isNavigationBarHidden

        super.init(nibName: nil, bundle: nil)

        self.title = title
        self.isModalInPresentation = isModalInPresentation
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let isBackActionAvailable: Bool
    let isNavigationBarHidden: Bool

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = ""
        navigationItem.setHidesBackButton(!isBackActionAvailable, animated: true)
    }
}

extension C42ViewController {
    var c42NavigationController: C42NavigationController? {
        navigationController as? C42NavigationController
    }

    func next(_ viewController: C42ViewController) {
        guard let navigationController = c42NavigationController
        else {
            fatalError()
        }

        navigationController.next(viewController)
    }

    func finish() {
        guard let navigationController = c42NavigationController
        else {
            fatalError()
        }

        navigationController.finish()
    }
}
