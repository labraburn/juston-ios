//
//  Created by Anton Spivak
//

import Foundation
import JustonMOON

public struct GithubMOON: JustonMOON {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var endpoint: URL {
        guard let url =
            URL(
                string: "https://labraburn.github.io/juston-configurations/wallet/mobile/"
            )
        else {
            fatalError("Can't happend.")
        }
        return url
    }
}
