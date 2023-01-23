//
//  Created by Anton Spivak
//

import CryptoKit
import Foundation

extension SecureEnclave {
    static var isDeviceAvailable: Bool {
        TARGET_OS_SIMULATOR == 0 && SecureEnclave.isAvailable
    }
}
