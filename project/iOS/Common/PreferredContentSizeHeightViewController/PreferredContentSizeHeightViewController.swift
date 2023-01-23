//
//  Created by Anton Spivak
//

import UIKit

protocol PreferredContentSizeHeightViewController: UIViewController {
    func preferredContentSizeHeight(
        with containerFrame: CGRect
    ) -> CGFloat
}
