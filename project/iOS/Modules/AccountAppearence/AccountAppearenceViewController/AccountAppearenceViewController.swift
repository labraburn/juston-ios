//
//  Created by Anton Spivak
//

import JustonCORE
import UIKit

class AccountAppearenceViewController: BaseAccountAppearenceViewController {
    // MARK: Lifecycle

    init(initialConfiguration: InitialConfiguration) {
        self.initialConfiguration = initialConfiguration
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    let initialConfiguration: InitialConfiguration

    override func viewDidLoad() {
        super.viewDidLoad()

        name = initialConfiguration.account.name
        style = initialConfiguration.account.appearance

        doneButton.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    }

    // MARK: Private

    // MARK: Actions

    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        let id = initialConfiguration.account.objectID

        let appearance = style
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty
        else {
            markNameTextViewAsError()
            return
        }

        Task { @PersistenceWritableActor in
            let object = PersistenceAccount.writeableObject(id: id)
            object.name = name
            object.appearance = appearance
            try? object.save()
        }

        hide(animated: true)
    }
}
