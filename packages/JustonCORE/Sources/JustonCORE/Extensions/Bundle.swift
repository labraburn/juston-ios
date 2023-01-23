//
//  Created by Anton Spivak
//

import Foundation

public extension Bundle {
    var releaseVersionNumber: String {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
    }

    var buildVersionNumber: String {
        return (infoDictionary?["CFBundleVersion"] as? String) ?? ""
    }
}
