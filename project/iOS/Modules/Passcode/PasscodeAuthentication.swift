//
//  Created by Anton Spivak
//

import JustonCORE
import LocalAuthentication
import UIKit

// MARK: - PasscodeAuthentication

actor PasscodeAuthentication {
    // MARK: Lifecycle

    init(inside viewController: UIViewController) {
        self.parole = SecureParole()
        self.containerViewController = viewController
    }

    // MARK: Internal

    let containerViewController: UIViewController

    func key() async throws -> Data {
        let isFaceIDSupported = await parole.isFaceIDSupported
        let isTouchIDSupported = await parole.isTouchIDSupported

        if isFaceIDSupported || isTouchIDSupported {
            return try await codeUsingBiometric()
        } else {
            return try await codeUsingPasscode()
        }
    }

    // MARK: Private

    private let parole: SecureParole
    private var passcodeContinuation: CheckedContinuation<Data, Error>?

    private func codeUsingBiometric() async throws -> Data {
        do {
            guard let key = try await parole.retrieveKeyWithUserPassword(nil)
            else {
                throw ApplicationError.noApplicationPassword
            }
            return key
        } catch is LAError {
            return try await codeUsingPasscode()
        } catch {
            throw error
        }
    }

    private func codeUsingPasscode() async throws -> Data {
        let task = Task<Data, Error> {
            try await withCheckedThrowingContinuation({ continuation in
                self.passcodeContinuation = continuation
            })
        }

        await MainActor.run(body: {
            let viewController = PasscodeViewController(mode: .get)
            viewController.delegate = self
            viewController.isModalInPresentation = true
            containerViewController.jus_present(viewController, animated: true)
        })

        return try await task.value
    }
}

// MARK: PasscodeViewControllerDelegate

extension PasscodeAuthentication: PasscodeViewControllerDelegate {
    @MainActor
    func passcodeViewController(
        _ viewController: PasscodeViewController,
        didFinishWithPasscode passcode: String
    ) {
        Task {
            do {
                guard let key = try await parole.retrieveKeyWithUserPassword(passcode)
                else {
                    throw ApplicationError.noApplicationPassword
                }

                viewController.dismiss(
                    animated: true,
                    completion: {
                        Task {
                            await self.passcodeContinuation?.resume(
                                returning: key
                            )
                        }
                    }
                )
            } catch SecureParoleError.wrongApplicationPassword {
                viewController.restart(
                    throwingError: true
                )
            } catch {
                viewController.dismiss(
                    animated: true,
                    completion: {
                        Task {
                            await self.passcodeContinuation?.resume(
                                throwing: error
                            )
                        }
                    }
                )
            }
        }
    }

    @MainActor
    func passcodeViewControllerDidCancel(_ viewController: PasscodeViewController) {
        viewController.dismiss(
            animated: true,
            completion: {
                Task {
                    await self.passcodeContinuation?.resume(
                        throwing: ApplicationError.userCancelled
                    )
                }
            }
        )
    }

    @MainActor
    func passcodeViewControllerDidRequireBiometry(_ viewController: PasscodeViewController) {
        Task {
            do {
                guard let key = try await parole.retrieveKeyWithUserPassword(nil)
                else {
                    throw ApplicationError.noApplicationPassword
                }

                viewController.dismiss(
                    animated: true,
                    completion: {
                        Task {
                            await self.passcodeContinuation?.resume(
                                returning: key
                            )
                        }
                    }
                )
            } catch {
                viewController.present(error)
            }
        }
    }
}
