//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

// MARK: - ApplicationDelegate

class ApplicationDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication.LaunchOptionsKey: Any
        ]? = nil
    ) -> Bool {
        WKWeb3URLSchemeHandler.hijack()

        JustonCORE.initialize()
        UIApplication.cleanLaunchScreenCache()

        application.requestRegisterForRemoteNotificationsIfNeeded()
        application.requestRemoteConfigurations()

        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration: UISceneConfiguration
        switch connectingSceneSession.role {
        case .windowApplication:
            sceneConfiguration = UISceneConfiguration(
                name: "Default",
                sessionRole: connectingSceneSession.role
            )
            sceneConfiguration.delegateClass = ApplicationWindowSceneDelegate
                .self
            sceneConfiguration.sceneClass = ApplicationWindowScene.self
        case .windowExternalDisplay:
            fatalError("Don't support external display.")
        default:
            fatalError("Scene role is unknown.")
        }

        return sceneConfiguration
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {}
}

// MARK: UNUserNotificationCenterDelegate

extension ApplicationDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
