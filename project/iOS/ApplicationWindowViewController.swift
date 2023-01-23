//
//  Created by Anton Spivak
//

import JustonUI
import UIKit

// MARK: - ApplicationWindowViewController

class ApplicationWindowViewController: ContainerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .jus_backgroundPrimary
    }
}

extension UIView {
    var applicationWindow: ApplicationWindow? {
        window as? ApplicationWindow
    }
}
