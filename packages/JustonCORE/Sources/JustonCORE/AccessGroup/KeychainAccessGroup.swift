//
//  Created by Anton Spivak
//

import Foundation

public struct KeychainAccessGroup: AccessGroup {
    // MARK: Lifecycle

    private init(_ label: String) {
        self.label = label
    }

    // MARK: Public

    #if DEBUG
    public static let shared: KeychainAccessGroup = .init(
        "RC58426QBN.group.com.hueton.debug.family"
    )
    #else
    public static let shared: KeychainAccessGroup = .init(
        "RC58426QBN.group.com.hueton.family"
    )
    #endif

    public let label: String
}
