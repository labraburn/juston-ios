//
//  Created by Anton Spivak
//

import JustonCORE
import UIKit

class OnboardingAccountAppearenceViewController: C42ConcreteViewController {
    // MARK: Lifecycle

    init(
        title: String,
        predefinedName: String?,
        completionBlock: @escaping CompletionBlock,
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        self.completionBlock = completionBlock
        super.init(
            title: title,
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
        appearanceViewController.name = predefinedName
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    typealias CompletionBlock = (
        _ viewController: C42ViewController,
        _ name: String,
        _ appearence: AccountAppearance
    ) async throws -> Void

    let completionBlock: CompletionBlock

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(appearanceViewController)
        appearanceViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appearanceViewController.view)
        appearanceViewController.view.pinned(edges: view)
        appearanceViewController.didMove(toParent: self)

        appearanceViewController.doneButton.addTarget(
            self,
            action: #selector(doneButtonDidClick(_:)),
            for: .touchUpInside
        )
    }

    // MARK: Private

    private let appearanceViewController = BaseAccountAppearenceViewController()

    private var task: Task<Void, Never>?

    private var locked: Bool = false {
        didSet {
            view.isUserInteractionEnabled = locked
        }
    }

    // MARK: Actions

    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        guard task == nil
        else {
            return
        }

        guard let name = appearanceViewController.name?
            .trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty
        else {
            appearanceViewController.markNameTextViewAsError()
            return
        }

        let style = appearanceViewController.style
        view.isUserInteractionEnabled = false

        task?.cancel()
        task = Task {
            do {
                try await self.completionBlock(self, name, style)
            } catch {
                present(error)
            }

            self.view.isUserInteractionEnabled = true
            self.task = nil
        }
    }
}
