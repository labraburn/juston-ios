//
//  Created by Anton Spivak
//

import Foundation
import UIKit

// MARK: - SignboardUpdates

public class SignboardUpdates {
    // MARK: Lifecycle

    internal init(letters: [SignboardLetter]) {
        self.letters = letters
    }

    // MARK: Public

    public let letters: [SignboardLetter]

    // MARK: Internal

    internal var completion: ((_ finished: Bool) -> Void)?

    // MARK: API

    func animate(
        sequence: [[SignboardTumbler]],
        duration: TimeInterval,
        infinity: Bool = false
    ) {
        animate(
            sequence: sequence,
            step: 0,
            duration: duration,
            infinity: infinity
        )
    }

    func animate(
        sequence: [[SignboardTumbler]],
        step: Int,
        duration: TimeInterval,
        infinity: Bool
    ) {
        guard sequence.count > 0,
              [letters.map({ $0.tumbler })] != sequence
        else {
            completion?(true)
            return
        }

        let reltime = duration / Double(sequence.count)
        UIView.animate(
            withDuration: reltime,
            delay: 0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                self?.apply(tumblers: sequence[step])
            },
            completion: { finished in
                var next = step + 1
                if infinity, next >= sequence.count {
                    next = 0
                }

                guard finished, next < sequence.count
                else {
                    self.completion?(finished)
                    return
                }

                // Self should be strong
                self.animate(
                    sequence: sequence,
                    step: next,
                    duration: duration,
                    infinity: infinity
                )
            }
        )
    }

    // MARK: Private

    private func apply(tumblers: [SignboardTumbler]) {
        #if DEBUG
        assert(tumblers.count == letters.count)
        #endif

        var index = 0
        letters.forEach({ letter in
            var tumbler = SignboardTumbler.off
            if tumblers.count >= letters.count {
                tumbler = tumblers[index]
            }
            letter.tumbler = tumbler
            index += 1
        })
    }
}

public extension SignboardUpdates {
    func on() {
        just([.on, .on, .on, .on, .on, .on])
    }

    func off() {
        just([.off, .off, .off, .off, .off, .off])
    }

    func just(_ tumblers: [SignboardTumbler]) {
        animate(
            sequence: [tumblers],
            duration: 0.1
        )
    }

    func trigger(completion: ((_ finished: Bool) -> Void)? = nil) {
        animate(
            sequence: [
                [.off, .off, .off, .off, .off, .off],
                [.off, .off, .off, .off, .off, .off],
                [.on, .off, .off, .off, .off, .off],
                [.off, .off, .off, .off, .off, .off],
                [.on, .off, .off, .off, .off, .off],
                [.on, .off, .off, .off, .on, .off],
                [.on, .off, .off, .off, .off, .off],
                [.on, .off, .on, .off, .on, .off],
                [.on, .off, .off, .off, .on, .off],
                [.on, .on, .on, .on, .on, .on],
            ],
            duration: 1
        )
    }

    func infinity(completion: ((_ finished: Bool) -> Void)? = nil) {
        animate(
            sequence: [
                [.off, .off, .off, .off, .off, .off],
                [.on, .off, .off, .off, .off, .off],
                [.on, .on, .off, .off, .off, .off],
                [.on, .on, .on, .off, .off, .off],
                [.on, .on, .on, .on, .off, .off],
                [.on, .on, .on, .on, .on, .off],
                [.on, .on, .on, .on, .on, .on],

                [.on, .on, .on, .on, .on, .on],
                [.off, .on, .on, .on, .on, .on],
                [.off, .off, .on, .on, .on, .on],
                [.off, .off, .off, .on, .on, .on],
                [.off, .off, .off, .off, .on, .on],
                [.off, .off, .off, .off, .off, .on],
                [.off, .off, .off, .off, .off, .off],

                [.off, .off, .off, .off, .off, .off],
                [.off, .off, .off, .off, .off, .on],
                [.off, .off, .off, .off, .on, .on],
                [.off, .off, .off, .on, .on, .on],
                [.off, .off, .on, .on, .on, .on],
                [.off, .on, .on, .on, .on, .on],
                [.on, .on, .on, .on, .on, .on],

                [.on, .on, .on, .on, .on, .on],
                [.on, .on, .on, .on, .on, .off],
                [.on, .on, .on, .on, .off, .off],
                [.on, .on, .on, .off, .off, .off],
                [.on, .on, .off, .off, .off, .off],
                [.on, .off, .off, .off, .off, .off],
                [.off, .off, .off, .off, .off, .off],
            ],
            duration: 2.1,
            infinity: true
        )
    }
}
