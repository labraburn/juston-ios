//
//  Created by Anton Spivak
//

import Foundation
import UIKit

// MARK: - InAppAnnouncementInfo

struct InAppAnnouncementInfo: InAppAnnouncement {
    typealias AnnouncementContent = Content

    struct Content {
        enum Icon {
            case info
            case success
            case copying
        }

        let text: String
        let icon: Icon
        let tintColor: UIColor
    }
}

extension InAppAnnouncementInfo.Content.Icon {
    var image: UIImage? {
        switch self {
        case .info: return .jus_info24
        case .success: return .jus_done24
        case .copying: return .jus_copy24
        }
    }
}

extension InAppAnnouncementInfo.Content {
    static let addressCopied = InAppAnnouncementInfo.Content(
        text: "AnnouncementAddressCopied".asLocalizedKey,
        icon: .copying,
        tintColor: .jus_letter_blue
    )

    static let wordsCopied = InAppAnnouncementInfo.Content(
        text: "AnnouncementWordsCopied".asLocalizedKey,
        icon: .copying,
        tintColor: .jus_letter_blue
    )

    static let transactionLinkCopied = InAppAnnouncementInfo.Content(
        text: "AnnouncementTransactionLinkCopied".asLocalizedKey,
        icon: .copying,
        tintColor: .jus_letter_blue
    )
}
