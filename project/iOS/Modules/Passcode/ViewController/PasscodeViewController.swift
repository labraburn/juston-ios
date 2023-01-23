//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

// MARK: - PasscodeViewControllerDelegate

protocol PasscodeViewControllerDelegate: AnyObject {
    @MainActor
    func passcodeViewController(
        _ viewController: PasscodeViewController,
        didFinishWithPasscode passcode: String
    )

    @MainActor
    func passcodeViewControllerDidCancel(
        _ viewController: PasscodeViewController
    )

    @MainActor
    func passcodeViewControllerDidRequireBiometry(
        _ viewController: PasscodeViewController
    )
}

// MARK: - PasscodeViewController

class PasscodeViewController: UIViewController {
    // MARK: Lifecycle

    init(mode: PasscodeMode) {
        switch mode {
        case .get:
            self.model = .get
        case .create:
            self.model = .create1Step
        }

        self.code = ""
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public func restart(throwingError: Bool) {
        switch model {
        case .get:
            break
        case .create1Step:
            break
        case .create2Step:
            model = .create1Step
        }

        if throwingError {
            feedbackGenerator.notificationOccurred(.error)
            passcodeHStackView.shake()
        }

        code = ""
        updatePasscodeViews()
    }

    // MARK: Internal

    enum PasscodeMode {
        case create
        case get
    }

    weak var delegate: PasscodeViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.font = .font(for: .headline)
        view.backgroundColor = .jus_backgroundPrimary

        faceIDButton.setImage(
            UIImage(
                systemName: "faceid",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 28)
            ),
            for: .normal
        )

        deleteButton.setImage(
            UIImage(
                systemName: "delete.left",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)
            ),
            for: .normal
        )

        cancelButton.title = "CANCEL"

        updatePasscodeViews()
    }

    // MARK: Fileprivate

    fileprivate enum PasscodeModel {
        case get

        case create1Step
        case create2Step(create1Code: String)
    }

    // MARK: Private

    @IBOutlet
    private weak var titleLabel: UILabel!
    @IBOutlet
    private weak var passcodeHStackView: UIStackView!

    @IBOutlet
    private weak var faceIDButton: UIButton!
    @IBOutlet
    private weak var deleteButton: UIButton!
    @IBOutlet
    private weak var cancelButton: TeritaryButton!

    private let feedbackGenerator = UINotificationFeedbackGenerator()

    private var model: PasscodeModel {
        didSet {
            updatePasscodeViews()
        }
    }

    private var code: String {
        didSet {
            updatePasscodeViews()
            finishIfNeeded()
        }
    }

    private func updatePasscodeViews() {
        switch model {
        case .get:
            break
        case .create1Step, .create2Step:
            cancelButton.isHidden = true

            // Settings alpha because superview of this button is UIStackView
            faceIDButton.alpha = 0
            faceIDButton.isUserInteractionEnabled = false
        }

        var index = 0
        passcodeHStackView.arrangedSubviews.forEach({ subview in
            guard let subview = subview as? PasscodeDotView
            else {
                return
            }
            subview.filled = code.count > index
            index += 1
        })

        titleLabel.text = model.text
    }

    private func finishIfNeeded() {
        guard code.count == 6
        else {
            return
        }

        switch model {
        case .get:
            delegate?.passcodeViewController(self, didFinishWithPasscode: code)
        case .create1Step:
            model = .create2Step(create1Code: code)
            code = ""
        case let .create2Step(create1Code):
            guard create1Code == code
            else {
                restart(throwingError: true)
                break
            }
            delegate?.passcodeViewController(self, didFinishWithPasscode: code)
        }
    }

    // MARK: Actions

    @IBAction
    private func numberButtonDidClick(_ sender: UIButton) {
        guard code.count < 6
        else {
            return
        }

        let number = "\(sender.tag)"
        code = "\(code)\(number)"
    }

    @IBAction
    private func biometryButtonDidClick(_ sender: UIButton) {
        delegate?.passcodeViewControllerDidRequireBiometry(self)
    }

    @IBAction
    private func deleteButtonDidClick(_ sender: UIButton) {
        guard code.count > 0
        else {
            return
        }

        code = String(code.dropLast())
    }

    @IBAction
    private func cancelButtonDidClick(_ sender: TeritaryButton) {
        delegate?.passcodeViewControllerDidCancel(self)
    }
}

private extension PasscodeViewController.PasscodeModel {
    var text: String {
        switch self {
        case .get:
            return "PasscodeViewEnterCode".asLocalizedKey
        case .create1Step:
            return "PasscodeViewCreateCode1".asLocalizedKey
        case .create2Step:
            return "PasscodeViewCreateCode2".asLocalizedKey
        }
    }
}
