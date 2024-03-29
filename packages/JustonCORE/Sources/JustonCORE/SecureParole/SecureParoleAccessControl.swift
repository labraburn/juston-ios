//
//  Created by Anton Spivak
//

import CryptoKit
import Foundation
import LocalAuthentication

// MARK: - SecureParoleAccessControl

@SecureParoleActor
internal enum SecureParoleAccessControl {
    case password(value: Data)
    case biometry

    // MARK: Internal

    var secAttrAccount: String {
        switch self {
        case .password:
            return "%@hcppp%@"
        case .biometry:
            return "%@hcpbb%@"
        }
    }

    var context: LAContext {
        let context = LAContext()
        context.touchIDAuthenticationAllowableReuseDuration = 5

        switch self {
        case let .password(value):
            let digest = SHA256.hash(data: value)
            context.setCredential(digest.data, type: .applicationPassword)
        case .biometry:
            break
        }

        return context
    }

    var secAccessControl: SecAccessControl {
        get throws {
            try _accessControlWithFlags(secAccessControlCreateFlags)
        }
    }

    // MARK: Private

    private var secAccessControlCreateFlags: SecAccessControlCreateFlags {
        var flags: SecAccessControlCreateFlags = []
        switch self {
        case .password:
            flags.insert(.applicationPassword)
        case .biometry:
            flags.insert(.biometryCurrentSet)
        }
        return flags
    }

    private func _accessControlWithFlags(
        _ flags: SecAccessControlCreateFlags
    ) throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        let secAccessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            flags,
            &error
        )

        guard let secAccessControl = secAccessControl
        else {
            throw SecureParoleError.underlyingCFError(error: error)
        }

        return secAccessControl
    }
}

@SecureParoleActor
private extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
