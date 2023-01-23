//
//  Created by Anton Spivak
//

import Foundation

extension NSObjectProtocol {
    func removeFromNotificationCenter() {
        NotificationCenter.default.removeObserver(self)
    }
}
