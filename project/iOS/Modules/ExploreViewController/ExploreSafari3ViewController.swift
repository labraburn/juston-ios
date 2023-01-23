//
//  Created by Anton Spivak
//

import UIKit

class ExploreSafari3ViewController: Safari3ViewController {
    override var childForHomeIndicatorAutoHidden: UIViewController? { nil }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    override var childForScreenEdgesDeferringSystemGestures: UIViewController? { nil }
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .bottom }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.window?.endEditing(true)
    }
}
