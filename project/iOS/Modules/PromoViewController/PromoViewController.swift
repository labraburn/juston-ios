//
//  Created by Anton Spivak
//

import UIKit

class PromoViewController: C42CollectionViewController {
    init(
        title: String,
        description: String,
        image: UIImage,
        completion: @MainActor @escaping () -> Void
    ) {
        super.init(
            title: title,
            sections: [
                .init(
                    section: .init(
                        kind: .simple
                    ),
                    items: [
                        .image(
                            image: image
                        ),
                        .label(
                            text: description,
                            kind: .body
                        ),
                    ]
                ),
                .init(
                    section: .init(kind: .simple),
                    items: [
                        .synchronousButton(
                            title: "CommonDone".asLocalizedKey,
                            kind: .primary,
                            action: { viewController in
                                completion()
                                viewController.hide(
                                    animated: true
                                )
                            }
                        ),
                    ]
                ),
            ],
            isModalInPresentation: false,
            isBackActionAvailable: true,
            isNavigationBarHidden: false
        )
    }
}
