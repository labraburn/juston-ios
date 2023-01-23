//
//  Created by Anton Spivak
//

import Foundation

extension String {
    var asLocalizedKey: String {
        Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
}
