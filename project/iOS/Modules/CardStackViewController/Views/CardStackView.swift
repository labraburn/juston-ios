//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit

// MARK: - CardStackViewDelegate

protocol CardStackViewDelegate: AnyObject {
    func cardStackView(
        _ view: CardStackView,
        didChangeSelectedModel model: CardStackCard?,
        manually: Bool
    )

    func cardStackView(
        _ view: CardStackView,
        didClickWhileModel model: CardStackCard
    )

    func cardStackView(
        _ view: CardStackView,
        didClickSendControl control: UIControl,
        model: CardStackCard
    )

    func cardStackView(
        _ view: CardStackView,
        didClickReceiveControl control: UIControl,
        model: CardStackCard
    )

    func cardStackView(
        _ view: CardStackView,
        didClickTopupControl control: UIControl,
        model: CardStackCard
    )

    func cardStackView(
        _ view: CardStackView,
        didClickMoreControl control: UIControl,
        model: CardStackCard
    )

    func cardStackView(
        _ view: CardStackView,
        didClickReadonlyControl control: UIControl,
        model: CardStackCard
    )

    func cardStackView(
        _ view: CardStackView,
        didClickVersionControl control: UIControl,
        model: CardStackCard
    )
}

// MARK: - CardStackView

final class CardStackView: UIView {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        clipsToBounds = false
        backgroundColor = .clear

        addSubview(containerView)

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(tapGestureDidUpdate(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(gestureRecongnizerDidUpdate(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.delaysTouchesBegan = false
        panGestureRecognizer.delaysTouchesEnded = false
        addGestureRecognizer(panGestureRecognizer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    enum Presentation {
        case large
        case compact
    }

    weak var delegate: CardStackViewDelegate?

    var cornerRadius: CGFloat = 0 {
        didSet {
            containerViewSubviews.forEach({ $0.cornerRadius = cornerRadius })
        }
    }

    var presentation: Presentation = .large {
        didSet {
            foregroundAnimator.removeAllBehaviors()
            backgroundAnimator.removeAllBehaviors()
            setNeedsLayoutSimple()
        }
    }

    private(set) var cards: [CardStackCard] = [] {
        didSet {
            selected = cards.first
        }
    }

    private(set) var selected: CardStackCard? {
        didSet {
            feedbackGenerator.impactOccurred()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard !isUserInteracting
        else {
            return
        }

        containerView.frame = bounds

        guard cachedBounds != bounds || needsLayoutAnimated || needsLayoutSimple
        else {
            return
        }

        layoutContainerViewSubviews(
            excludePositiongOfView: nil,
            animated: needsLayoutAnimated
        )

        cachedBounds = bounds
        setUnneedsLayout()
    }

    func setNeedsLayoutSimple() {
        super.setNeedsLayout()
        needsLayoutSimple = true
    }

    func setNeedsLayoutAnimated() {
        super.setNeedsLayout()
        needsLayoutAnimated = true
    }

    func setUnneedsLayout() {
        super.setNeedsLayout()
        needsLayoutAnimated = false
        needsLayoutSimple = false
    }

    func update(cards: [CardStackCard], animated: Bool) {
        guard !isUserInteracting
        else {
            return
        }

        guard self.cards != cards
        else {
            return
        }

        self.cards = cards
        delegate?.cardStackView(
            self,
            didChangeSelectedModel: selected,
            manually: false
        )

        reloadData(animated)
    }

    // MARK: Private

    @MainActor
    private struct UserInteractionSession {
        let viewInitialCenter: CGPoint
    }

    private static let minimumCardSize = CGSize(width: 90, height: 90)

    private var userInteractionSession: UserInteractionSession?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    private var needsLayoutAnimated = false
    private var needsLayoutSimple = false
    private var cachedBounds = CGRect.zero

    private var containerView: UIView = .init().with({
        $0.backgroundColor = .clear
    })

    private lazy var backgroundAnimator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: containerView)
        return animator
    }()

    private lazy var foregroundAnimator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: containerView)
        return animator
    }()

    private var containerViewSubviews: [CardStackCardView] {
        containerView.subviews.compactMap({ $0 as? CardStackCardView })
    }

    private var isUserInteracting: Bool {
        userInteractionSession != nil
    }

    private func reloadData(_ animated: Bool) {
        containerViewSubviews.forEach({ $0.removeFromSuperview() })

        var index = 0
        cards.reversed().forEach({ model in
            let view = CardStackCardView(model: model)
            view.bounds = containerSubviewViewBounds(at: index)
            view.center = containerSubviewViewPosition(at: index)
            view.cornerRadius = cornerRadius
            view.delegate = self

            if window != nil {
                view.layoutIfNeeded()
            }

            containerView.addSubview(view)
            index += 1
        })

        if animated {
            setNeedsLayoutAnimated()
        } else {
            setNeedsLayoutSimple()
        }
    }

    private func layoutContainerViewSubviews(
        excludePositiongOfView: UIView? = nil,
        animated: Bool
    ) {
        let shouldStartFrom0Alpha = containerViewSubviews.filter({ $0.state != .hidden })
            .count == containerViewSubviews.count

        var index = 0
        containerViewSubviews.reversed().forEach({ view in

            if view.bounds.size == CardStackView.minimumCardSize {
                // Guess it's initial state of view
                view.center = CGPoint(
                    x: self.bounds.midX,
                    y: self.bounds.height / 3 * 2
                )
            }

            let bounds = self.containerSubviewViewBounds(at: index)
            if view.bounds != bounds {
                view.bounds = bounds
                view.layoutIfNeeded()
            }

            let animations = {
                if view != excludePositiongOfView {
                    view.center = self.containerSubviewViewPosition(at: index)
                    view.alpha = self.containerSubviewViewAlpha(at: index)
                    view.isHidden = view.alpha == 0
                }

                view.transform = .identity
                view.update(
                    state: index == 0 ? self.presentation.cardViewState : .hidden,
                    animated: animated
                )
            }

            if shouldStartFrom0Alpha {
                view.alpha = 0
            }

            if animated {
                UIView.performWithDefaultAnimation(
                    duration: 0.86,
                    block: animations
                )
            } else {
                animations()
            }

            index += 1
        })
    }

    private func containerSubviewViewPosition(at index: Int) -> CGPoint {
        let bounds = containerSubviewViewBounds(at: index)
        return CGPoint(
            x: bounds.midX + (self.bounds.width - bounds.width) / 2,
            y: bounds.midY + CGFloat(index) * -2 - (self.bounds.height - bounds.height) / 2
        )
    }

    private func containerSubviewViewBounds(at index: Int) -> CGRect {
        let size = CardStackView.minimumCardSize
        let offset = CGFloat(index) * 6
        return CGRect(
            x: 0,
            y: 0,
            width: max(bounds.width - offset, size.width), // minimum size for constraints errors
            height: max(bounds.height - offset, size.height) // minimum size for constraints errors
        )
    }

    private func containerSubviewViewAlpha(at index: Int) -> CGFloat {
        max(1 - 0.36 * CGFloat(index), 0)
    }

    private func popLastAndLayoutContainerViewSubviews(velocity: CGPoint) {
        backgroundAnimator.removeAllBehaviors()

        guard let card = containerViewSubviews.last
        else {
            return
        }

        let snapBehaviour = UISnapBehavior(
            item: card,
            snapTo: containerSubviewViewPosition(at: containerViewSubviews.count - 1)
        )

        let itemBehaviour = UIDynamicItemBehavior(items: [card])
        itemBehaviour.addLinearVelocity(velocity, for: card)

        backgroundAnimator.addBehavior(snapBehaviour)
        backgroundAnimator.addBehavior(itemBehaviour)

        let popped = cards[0]

        cards = Array(cards[1 ..< cards.count]) + [popped]
        delegate?.cardStackView(
            self,
            didChangeSelectedModel: selected,
            manually: true
        )

        containerView.sendSubviewToBack(card)

        let alpha = containerSubviewViewAlpha(at: containerViewSubviews.count - 1)
        UIView.animate(
            withDuration: 0.93,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                card.alpha = alpha
            }, completion: { _ in
                card.isHidden = alpha == 0
            }
        )

        layoutContainerViewSubviews(
            excludePositiongOfView: card,
            animated: true
        )
    }

    private func returnLastToTop(velocity: CGPoint) {
        guard let card = containerViewSubviews.last
        else {
            return
        }

        let itemBehaviour = UIDynamicItemBehavior(items: [card])
        itemBehaviour.addLinearVelocity(velocity, for: card)

        let snapBehaviour = UISnapBehavior(
            item: card,
            snapTo: containerSubviewViewPosition(at: 0)
        )

        foregroundAnimator.addBehavior(snapBehaviour)
        foregroundAnimator.addBehavior(itemBehaviour)

        feedbackGenerator.impactOccurred(intensity: 0.42)
    }

    private func removeAllDynamicAnimations() {
        foregroundAnimator.removeAllBehaviors()
    }

    @objc
    private func gestureRecongnizerDidUpdate(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let card = containerViewSubviews.last
        else {
            return
        }

        switch gestureRecognizer.state {
        case .began, .possible:
            removeAllDynamicAnimations()
            userInteractionSession = UserInteractionSession(
                viewInitialCenter: CGPoint(x: bounds.midX, y: bounds.midY)
            )
        case .changed:
            guard let userInteractionSession = userInteractionSession
            else {
                return
            }

            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            card.center = CGPoint(
                x: userInteractionSession.viewInitialCenter.x + translation.x,
                y: userInteractionSession.viewInitialCenter.y + translation.y
            )
        case .cancelled, .ended, .failed:
            guard let userInteractionSession = userInteractionSession
            else {
                return
            }

            self.userInteractionSession = nil

            let viewInitialCenter = userInteractionSession.viewInitialCenter

            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let projection = gestureRecognizer.projection(from: viewInitialCenter)
            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)

            if (projection.x < -700 && translation.x < 0) ||
                (projection.x > 700 && translation.x > 0) ||
                (translation.x > bounds.width / 3 * 1.7 && velocity.x > 42) ||
                (translation.x < -bounds.width / 3 * 1.7 && velocity.x < -42)
            {
                popLastAndLayoutContainerViewSubviews(velocity: velocity)
            } else {
                returnLastToTop(velocity: velocity)
            }
        @unknown default:
            break
        }
    }

    @objc
    private func tapGestureDidUpdate(_ gestureRecognizer: UITapGestureRecognizer) {
        guard !isUserInteracting,
              let selected = selected
        else {
            return
        }

        delegate?.cardStackView(self, didClickWhileModel: selected)
    }
}

// MARK: UIGestureRecognizerDelegate

extension CardStackView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = gestureRecognizer as? UITapGestureRecognizer {
            guard let hitTest = hitTest(gestureRecognizer.location(in: self), with: nil)
            else {
                return true
            }

            return !hitTest.isKind(of: UIControl.self)
        }

        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            guard cards.count > 1
            else {
                return false
            }

            let velocity = panGestureRecognizer.velocity(in: gestureRecognizer.view)
            return abs(velocity.x) * 1.42 > abs(velocity.y)
        }

        return true
    }
}

// Inspired via
// https://github.com/jenox/UIKit-Playground/tree/master/02-Gestures-In-Fluid-Interfaces/
extension UIPanGestureRecognizer {
    func projection(from currentPosition: CGPoint) -> CGPoint {
        var _velocity = velocity(in: view)

        if _velocity.x != 0 || _velocity.y != 0 {
            let max = max(abs(_velocity.x), abs(_velocity.y))
            _velocity.x *= abs(_velocity.x / max)
            _velocity.y *= abs(_velocity.y / max)
        }

        return project(_velocity, onto: currentPosition)
    }

    func project(
        _ velocity: CGPoint,
        onto position: CGPoint,
        decelerationRate: UIScrollView.DecelerationRate = .normal
    ) -> CGPoint {
        let factor = -1 / (1000 * log(decelerationRate.rawValue))
        return CGPoint(
            x: position.x + factor * velocity.x,
            y: position.y + factor * velocity.y
        )
    }
}

private extension UIView {
    static func performWithDefaultAnimation(
        duration: TimeInterval = 0.21,
        block: @escaping () -> Void,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
            animations: block,
            completion: { _ in
                completion?()
            }
        )
    }
}

private extension CardStackView.Presentation {
    var cardViewState: CardStackCardView.State {
        switch self {
        case .large:
            return .large
        case .compact:
            return .compact
        }
    }
}

// MARK: - CardStackView + CardStackCardViewDelegate

extension CardStackView: CardStackCardViewDelegate {
    func cardStackCardView(
        _ view: UIView,
        didClickSendControl control: UIControl,
        model: CardStackCard
    ) {
        delegate?.cardStackView(
            self,
            didClickSendControl: control,
            model: model
        )
    }

    func cardStackCardView(
        _ view: UIView,
        didClickReceiveControl control: UIControl,
        model: CardStackCard
    ) {
        delegate?.cardStackView(
            self,
            didClickReceiveControl: control,
            model: model
        )
    }

    func cardStackCardView(
        _ view: UIView,
        didClickTopupControl control: UIControl,
        model: CardStackCard
    ) {
        delegate?.cardStackView(
            self,
            didClickTopupControl: control,
            model: model
        )
    }

    func cardStackCardView(
        _ view: UIView,
        didClickMoreControl control: UIControl,
        model: CardStackCard
    ) {
        delegate?.cardStackView(
            self,
            didClickMoreControl: control,
            model: model
        )
    }

    func cardStackCardView(
        _ view: UIView,
        didClickReadonlyControl control: UIControl,
        model: CardStackCard
    ) {
        delegate?.cardStackView(
            self,
            didClickReadonlyControl: control,
            model: model
        )
    }

    func cardStackCardView(
        _ view: UIView,
        didClickVersionControl control: UIControl,
        model: CardStackCard
    ) {
        delegate?.cardStackView(
            self,
            didClickVersionControl: control,
            model: model
        )
    }
}
