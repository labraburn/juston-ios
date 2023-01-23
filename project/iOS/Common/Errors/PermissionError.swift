//
//  Created by Anton Spivak
//

import Foundation

// MARK: - PermissionError

protocol PermissionError: LocalizedError {}

// MARK: - CameraPermissionError

enum CameraPermissionError {
    case noCameraAccessQRCode
}

// MARK: PermissionError

extension CameraPermissionError: PermissionError {
    var errorDescription: String? {
        switch self {
        case .noCameraAccessQRCode:
            return "PermissionErrorCameraAccessQRCode".asLocalizedKey
        }
    }
}

// MARK: - NotificationsPermissionError

enum NotificationsPermissionError {
    case notEnabledDeveloper
}

// MARK: PermissionError

extension NotificationsPermissionError: PermissionError {
    var errorDescription: String? {
        switch self {
        case .notEnabledDeveloper:
            return "PermissionErrorNotificationsNotEnabled".asLocalizedKey
        }
    }
}
