//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

// MARK: - AlertViewController

class AlertViewController: UIViewController {
    // MARK: Lifecycle

    init(
        image: AlertViewControllerImage? = nil,
        title: String?,
        message: String? = nil,
        actions: [Action] = []
    ) {
        self.image = image
        self.message = message
        self.actions = actions

        super.init(nibName: nil, bundle: nil)

        self.title = title
        self.transitioningDelegate = _transitioningDelegate
        self.modalPresentationStyle = .custom
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    struct Action {
        enum Style {
            case `default`
            case cancel
            case destructive
        }

        static let done = Action(
            title: "CommonDone".asLocalizedKey,
            block: { $0.dismiss(animated: true) },
            style: .cancel
        )

        static let cancel = Action(
            title: "CommonCancel".asLocalizedKey,
            block: { $0.dismiss(animated: true) },
            style: .cancel
        )

        static let settings = Action(
            title: "CommonSettings".asLocalizedKey,
            block: {
                $0.open(url: URL(string: UIApplication.openSettingsURLString))
                $0.dismiss(animated: true)
            },
            style: .default
        )

        static let ok = Action(
            title: "CommonOK".asLocalizedKey,
            block: { $0.dismiss(animated: true) },
            style: .cancel
        )

        let title: String
        let block: (_ viewController: AlertViewController) -> Void
        let style: Style
    }

    let image: AlertViewControllerImage?
    let message: String?
    let actions: [Action]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 24
        view.backgroundColor = .jus_backgroundSecondary
        view.addSubview(verticalStackView)
        NSLayoutConstraint.activate {
            verticalStackView.pin(vertically: view, top: 24, bottom: 24)
            verticalStackView.pin(horizontally: view, left: 24, right: 24)
        }

        if let image = image {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = image.image
            imageView.setContentHuggingPriority(.required, for: .vertical)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = image.tintColor
            verticalStackView.addArrangedSubview(imageView)
        }

        if let title = title, !title.isEmpty {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = .font(for: .title2)
            titleLabel.text = title
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.setContentHuggingPriority(.required, for: .vertical)
            verticalStackView.addArrangedSubview(titleLabel)
        }

        if let message = message, !message.isEmpty {
            let messageLabel = UILabel()
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.font = .font(for: .body)
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.setContentHuggingPriority(.required, for: .vertical)
            verticalStackView.addArrangedSubview(messageLabel)
        }

        var index = 0
        actions.forEach({ action in
            let button = AlertViewControllerButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.insertVisualEffectViewWithEffect(
                UIBlurEffect(style: .systemUltraThinMaterialDark),
                cornerRadius: 26,
                cornerCurve: .circular
            )
            button.insertHighlightingScaleAnimation()
            button.insertFeedbackGenerator(style: .medium)
            button.setContentHuggingPriority(.required, for: .vertical)
            button.heightAnchor.pin(to: 52).isActive = true
            button.tag = index
            button.addTarget(self, action: #selector(actionButtonDidClick(_:)), for: .touchUpInside)
            switch action.style {
            case .default:
                button.tintColor = .jus_textPrimary
                button.setAttributedTitle(
                    .string(action.title, with: .body, foregroundColor: .jus_textPrimary),
                    for: .normal
                )
            case .destructive:
                button.tintColor = .jus_letter_red
                button.setAttributedTitle(
                    .string(action.title, with: .body, foregroundColor: .jus_letter_red),
                    for: .normal
                )
            case .cancel:
                button.tintColor = .jus_textPrimary
                button.setAttributedTitle(
                    .string(action.title, with: .headline, foregroundColor: .jus_textPrimary),
                    for: .normal
                )
            }
            verticalStackView.addArrangedSubview(button)
            index += 1
        })
    }

    // MARK: Private

    private let _transitioningDelegate = AlertViewControllerTransitioningDelegate()

    private let verticalStackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 16
        $0.distribution = .fill
    })

    // MARK: Actions

    @objc
    private func actionButtonDidClick(_ sender: UIButton) {
        actions[sender.tag].block(self)
    }
}

// MARK: - AlertViewControllerButton

private final class AlertViewControllerButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.applyFigmaShadow(
            color: .init(rgb: 0x232020),
            alpha: 0.24,
            x: 0,
            y: 12,
            blur: 12,
            spread: 0,
            cornerRadius: 10
        )
    }
}
