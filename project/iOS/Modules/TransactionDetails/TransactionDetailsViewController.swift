//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import SafariServices
import UIKit

// MARK: - TransactionDetailsViewController

class TransactionDetailsViewController: UIViewController {
    // MARK: Lifecycle

    init(
        account: PersistenceAccount,
        transaction: TransactionDetailsViewable
    ) {
        self.account = account
        self.transaction = transaction

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "TransactionDetailsTitle".asLocalizedKey
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .jus_backgroundPrimary

        view.addSubview(valueLabel)
        view.addSubview(textLabel)
        view.addSubview(openWEBButton)
        view.addSubview(copyLinkButton)
        view.addSubview(doneButton)

        let (
            textColor,
            valuePrefix,
            recipientsOrSender
        ) = { () -> (UIColor, String, Set<ConcreteAddress>) in
            switch transaction.kind {
            case .pending:
                return (.jus_textPrimary, "-", Set(transaction.to))
            case .out:
                return (.jus_letter_red, "-", Set(transaction.to))
            case .in:
                return (
                    .jus_letter_green,
                    "+",
                    [transaction.from ?? account.convienceSelectedAddress]
                )
            }
        }()

        let value = CurrencyFormatter.string(from: transaction.value, options: .maximum9minimum9)
        let values = value.components(separatedBy: ".")

        valueLabel.attributedText = NSMutableAttributedString().with({
            $0.append(NSAttributedString(string: "\(valuePrefix)\(values[0])", attributes: [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 57, weight: .heavy),
                .foregroundColor: textColor,
                .paragraphStyle: NSMutableParagraphStyle().with({
                    $0.alignment = .center
                    $0.maximumLineHeight = 57
                    $0.minimumLineHeight = 57
                }),
            ]))
            $0.append(NSAttributedString(string: "\n." + values[1], attributes: [
                .font: UIFont.font(for: .body),
                .foregroundColor: textColor,
                .kern: 4,
                .paragraphStyle: NSMutableParagraphStyle().with({
                    $0.alignment = .center
                }),
            ]))
        })

        let recipientsOrSenders = recipientsOrSender.reduce(
            into: "",
            {
                $0 = $0 + "\($1)\n"
            }
        )

        let spacing = NSAttributedString("\n\u{200A}\n", with: .body, lineHeight: 2)
        textLabel.attributedText = NSMutableAttributedString({
            switch transaction.kind {
            case .out, .pending:
                NSAttributedString(
                    "\("TransactionDetailsRecipients".asLocalizedKey):",
                    with: .subheadline,
                    foregroundColor: .jus_textSecondary
                )
            case .in:
                NSAttributedString(
                    "\("TransactionDetailsSender".asLocalizedKey):",
                    with: .subheadline,
                    foregroundColor: .jus_textSecondary
                )
            }
            spacing
            NSAttributedString("\(recipientsOrSenders)\n", with: .body)

            NSAttributedString(
                "\("TransactionDetailsDate".asLocalizedKey):",
                with: .subheadline,
                foregroundColor: .jus_textSecondary
            )
            spacing
            NSAttributedString("\(formatter.string(from: transaction.date))\n\n", with: .body)

            NSAttributedString(
                "\("TransactionDetailsFees".asLocalizedKey):",
                with: .subheadline,
                foregroundColor: .jus_textSecondary
            )
            spacing
            NSAttributedString("\(transaction.fees.string(with: .maximum9))\n\n", with: .body)

            if let message = transaction.message {
                NSAttributedString(
                    "\("TransactionDetailsMessage".asLocalizedKey):",
                    with: .subheadline,
                    foregroundColor: .jus_textSecondary
                )
                spacing
                NSAttributedString("\(message)\n\n", with: .body)
            }
        })

        NSLayoutConstraint.activate({
            valueLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 8)
            valueLabel.heightAnchor.pin(greaterThan: 121)
            valueLabel.pin(horizontally: view, left: 16, right: 16)

            textLabel.topAnchor.pin(to: valueLabel.bottomAnchor, constant: 12)
            textLabel.pin(horizontally: view, left: 16, right: 16)

            copyLinkButton.topAnchor.pin(to: textLabel.bottomAnchor, constant: 16)
            copyLinkButton.pin(horizontally: view, left: 16, right: 16)

            openWEBButton.topAnchor.pin(to: copyLinkButton.bottomAnchor, constant: 16)
            openWEBButton.pin(horizontally: view, left: 16, right: 16)

            doneButton.topAnchor.pin(to: openWEBButton.bottomAnchor, constant: 8)
            doneButton.pin(horizontally: view, left: 16, right: 16)

            view.safeAreaLayoutGuide.bottomAnchor.pin(to: doneButton.bottomAnchor, constant: 8)
        })
    }

    // MARK: Private

    private let valueLabel = BorderedLabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.lineBreakMode = .byCharWrapping
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })

    private let textLabel = UITextView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isEditable = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
    })

    private lazy var copyLinkButton = PrimaryButton(
        title: "TransactionDetailsCopyLink"
            .asLocalizedKey.uppercased()
    ).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(copyLinkButtonDidClick(_:)), for: .touchUpInside)
    })

    private lazy var openWEBButton = PrimaryButton(
        title: "TransactionDetailsOpenScanButton"
            .asLocalizedKey.uppercased()
    ).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(openWEBButtonDidClick(_:)), for: .touchUpInside)
    })

    private lazy var doneButton = TeritaryButton(title: "CommonDone".asLocalizedKey.uppercased())
        .with({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
        })

    private let account: PersistenceAccount
    private let transaction: TransactionDetailsViewable
    private let formatter: DateFormatter = .init().with({
        $0.dateFormat = "MMMM d, HH:mm"
    })

    private func transactionURL() throws -> URL {
        guard let id = transaction.transactionID
        else {
            throw TransactionError.isPending
        }

        let address = account.convienceSelectedAddress.description
        let hash = id.hash.base64EncodedString()

        guard let url = URL(string: "https://tonscan.org/tx/\(id.logicalTime):\(hash):\(address)")
        else {
            throw URLError(.badURL)
        }

        return url
    }

    // MARK: Actions

    @objc
    private func copyLinkButtonDidClick(_ sender: UIButton) {
        do {
            let url = try transactionURL()

            InAppAnnouncementCenter.shared.post(
                announcement: InAppAnnouncementInfo.self,
                with: .transactionLinkCopied
            )

            UIPasteboard.general.string = url.absoluteString
        } catch {
            present(error)
        }
    }

    @objc
    private func openWEBButtonDidClick(_ sender: UIButton) {
        do {
            let url = try transactionURL()
            open(url: url, options: .internalBrowser)
        } catch {
            present(error)
        }
    }

    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        hide(animated: true)
    }
}

// MARK: - BorderedLabel

private class BorderedLabel: UILabel {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        _init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }

    // MARK: Private

    private let borderView =
        GradientBorderedView(colors: [UIColor(rgb: 0x85FFC4), UIColor(rgb: 0xBC85FF)]).with({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.cornerRadius = 12
        })

    private func _init() {
        addSubview(borderView)
        borderView.pinned(edges: self)
    }
}
