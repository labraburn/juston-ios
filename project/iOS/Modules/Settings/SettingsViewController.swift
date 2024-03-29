//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import MessageUI
import UIKit

// MARK: - SettingsViewController

class SettingsViewController: C42CollectionViewController {
    init(
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        super.init(
            title: "SettingsTitle".asLocalizedKey,
            sections: [
                // Application logo
                .init(
                    section: .init(
                        kind: .simple,
                        header: .logo(
                            secretAction: { viewController in
                                (viewController as? SettingsViewController)?
                                    .openDeveloperViewController()
                            }
                        )
                    ),
                    items: []
                ),
                // Description
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .text(
                            value: "SettingsDescription".asLocalizedKey,
                            numberOfLines: 0,
                            textAligment: .center
                        ),
                    ]
                ),
                // General
                .init(
                    section: .init(
                        kind: .simple,
                        header: .none
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsShareButton".asLocalizedKey,
                            titleColor: .jus_letter_blue,
                            action: { viewController in
                                let items = [URL.juston]
                                let activityViewController = UIActivityViewController(
                                    activityItems: items,
                                    applicationActivities: nil
                                )
                                viewController.jus_present(activityViewController, animated: true)
                            }
                        ),
                        .settingsButton(
                            title: "SettingsRateButton".asLocalizedKey,
                            titleColor: .jus_letter_blue,
                            action: { viewController in
                                viewController.open(url: .appStore)
                            }
                        ),
                    ]
                ),
                // System settings
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "SettingsSystemSettingsTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .jus_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsNotificationsButton".asLocalizedKey,
                            titleColor: .jus_letter_purple,
                            action: { viewController in
                                let url = URL(string: UIApplication.openSettingsURLString)
                                viewController.open(url: url)
                            }
                        ),
                    ]
                ),
                // Agreements
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "SettingsAgreementsTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .jus_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsPrivacyPolicyButton".asLocalizedKey,
                            titleColor: .jus_letter_violet,
                            action: { viewController in
                                viewController.open(
                                    url: .privacyPolicy,
                                    options: .internalBrowser
                                )
                            }
                        ),
                        .settingsButton(
                            title: "SettingsTermsOfUseButton".asLocalizedKey,
                            titleColor: .jus_letter_violet,
                            action: { viewController in
                                viewController.open(
                                    url: .termsOfUse,
                                    options: .internalBrowser
                                )
                            }
                        ),
                    ]
                ),
                // Support
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "SettingsSupportTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .jus_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsContactDeveloperButton".asLocalizedKey,
                            titleColor: .jus_letter_yellow,
                            action: { viewController in
                                (viewController as? SettingsViewController)?
                                    .openMailComposeViewControllerIfAvailable()
                            }
                        ),
                        .settingsButton(
                            title: "SettingsCommunityChatButton".asLocalizedKey,
                            titleColor: .jus_letter_yellow,
                            action: { viewController in
                                viewController.open(url: .telegramChat)
                            }
                        ),
                    ]
                ),
                // Social networks
                .init(
                    section: .init(
                        kind: .simple,
                        header: .title(
                            value: "SettingsSocialTitle".asLocalizedKey,
                            textAligment: .center,
                            foregroundColor: .jus_textPrimary
                        )
                    ),
                    items: [
                        .settingsButton(
                            title: "SettingsTelegramButton".asLocalizedKey,
                            titleColor: .jus_letter_green,
                            action: { viewController in
                                viewController.open(url: .telegramChannel)
                            }
                        ),
                    ]
                ),
            ],
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
}

extension SettingsViewController {
    func openDeveloperViewController() {
        next(DeveloperViewController())
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func openMailComposeViewControllerIfAvailable() {
        let email = "hello@juston.io"
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients([email])
            jus_present(mailComposeViewController, animated: true)
        } else {
            let url = URL(string: "mailto:\(email)")
            open(url: url)
        }
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
