//
//  Created by Anton Spivak
//

import Foundation
import JustonCORE

extension OnboardingNavigationController {
    struct InitialConfiguration {
        enum Screen: Equatable {
            case welcome
            case agreements
            case passcode
            case account
        }

        let screens: Set<Screen>
    }
}

extension OnboardingNavigationController.InitialConfiguration {
    static func dependsUserDefaults() async -> OnboardingNavigationController.InitialConfiguration {
        var set: Set<Screen> = []

        if !UDS.isWelcomeScreenViewed {
            set.insert(.welcome)
        }

        if !UDS.isAgreementsAccepted {
            set.insert(.agreements)
        }

        let parole = SecureParole()
        let isKeyGenerated = await parole.isKeyGenerated
        if !isKeyGenerated {
            // Force welcome and agreements
            set.insert(.welcome)
            set.insert(.agreements)

            set.insert(.passcode)
        }

        set.insert(.account)

        return .init(screens: set)
    }
}
