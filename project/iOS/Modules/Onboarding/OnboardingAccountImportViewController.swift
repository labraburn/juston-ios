//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

// MARK: - OnboardingAccountImportViewController

class OnboardingAccountImportViewController: C42ConcreteViewController {
    // MARK: Lifecycle

    init(
        completionBlock: @escaping CompletionBlock,
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        self.completionBlock = completionBlock
        super.init(
            title: "OnboardingImportTitle".asLocalizedKey,
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    enum Result {
        case words(value: [String])
        case address(value: String)
    }

    typealias CompletionBlock = (
        _ viewController: C42ViewController,
        _ result: Result
    ) async throws -> Void

    lazy var nextButton = PrimaryButton(title: "OnboardingNextButton".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(nextButtonDidClick(_:)), for: .touchUpInside)
    })

    let completionBlock: CompletionBlock

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .jus_backgroundPrimary

        view.addSubview(descriptionLabel)
        view.addSubview(inputTextView)
        view.addSubview(nextButton)

        inputTextView.actions = [
            .init(
                image: .jus_scan20,
                block: { [weak self] in
                    self?.scanQRAndFill()
                }
            ),
        ]

        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)

            inputTextView.topAnchor.pin(to: descriptionLabel.bottomAnchor, constant: 32)
            inputTextView.pin(horizontally: view, left: 16, right: 16)

            nextButton.topAnchor.pin(greaterThan: inputTextView.bottomAnchor, constant: 24)
            nextButton.pin(horizontally: view, left: 16, right: 16)

            view.safeAreaLayoutGuide.bottomAnchor.pin(to: nextButton.bottomAnchor, constant: 8)
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(false)
    }

    // MARK: Fileprivate

    fileprivate func result(from textView: UITextView) -> Result? {
        guard textView.hasText
        else {
            return nil
        }

        let words = (textView.text?.split(whereSeparator: { !$0.isLetter }) ?? [])
            .map({ String($0) })
        if words.count == 24 {
            return .words(value: words)
        } else if let _ = ConcreteAddress(string: textView.text) {
            return .address(value: textView.text)
        } else if DNSAddress.isTONDomain(string: textView.text) {
            return .address(value: textView.text)
        } else {
            return nil
        }
    }

    fileprivate func markTextViewErrorIfNeeded() {
        guard result(from: inputTextView.textView) == nil
        else {
            return
        }

        markTextViewError()
    }

    fileprivate func markTextViewError() {
        inputTextView.shake()
        inputTextView.textView.textColor = .jus_letter_red
        errorFeedbackGenerator.impactOccurred()
    }

    // MARK: Private

    private let errorFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .jus_textPrimary
        $0.text = "OnboardingImportDescription".asLocalizedKey
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })

    private lazy var inputTextView = BorderedTextView(
        caption: "OnboardingImportTitleCaption".asLocalizedKey
    ).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .asciiCapable
        $0.textView.returnKeyType = .done
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 64
        $0.textView.maximumContentSizeHeight = 96
        $0.heightAnchor.pin(lessThan: 256).isActive = true
    })

    private func scanQRAndFill() {
        let qrViewController = CameraViewController()
        qrViewController.delegate = self

        let navigationController = NavigationController(rootViewController: qrViewController)
        jus_present(navigationController, animated: true, completion: nil)
    }

    // MARK: Actions

    @objc
    private func nextButtonDidClick(_ sender: UIButton) {
        guard let result = result(from: inputTextView.textView)
        else {
            markTextViewErrorIfNeeded()
            return
        }

        nextButton.startAsynchronousOperation({ @MainActor in
            do {
                try await self.completionBlock(self, result)
            } catch AddressError.unparsable {
                self.markTextViewError()
            } catch {
                self.present(error)
            }
        })
    }
}

// MARK: UITextViewDelegate

extension OnboardingAccountImportViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        inputTextView.setFocused(true)
        textView.textColor = .white
        return true
    }

    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        if text.count > 1 {
            // copy/paste

            DispatchQueue.main.async(execute: {
                if self.result(from: textView) != nil {
                    textView.resignFirstResponder()
                }
            })

            return true
        } else if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {}

    func textViewDidEndEditing(_ textView: UITextView) {
        inputTextView.setFocused(false)
        markTextViewErrorIfNeeded()
    }
}

// MARK: CameraViewControllerDelegate

extension OnboardingAccountImportViewController: CameraViewControllerDelegate {
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeSchemeURL schemeURL: SchemeURL
    ) {
        viewController.hide(animated: true)
        switch schemeURL {
        case let .transfer(_, configuration):
            inputTextView.textView.text = configuration.destination.displayName
        }
    }
}
