//
//  Created by Anton Spivak
//

import JustonCORE
import JustonUI
import UIKit
import WebKit

// MARK: - Safari3BrowserViewControllerDelegate

protocol Safari3BrowserViewControllerDelegate: AnyObject {
    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeURL url: URL?
    )

    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        titleDidChange title: String?
    )

    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        didChangeLoading loading: Bool
    )

    func safari3Browser(
        _ viewController: Safari3BrowserViewController,
        wantsHomeWhileError error: Error?
    )
}

// MARK: - Safari3BrowserViewController

class Safari3BrowserViewController: UIViewController {
    // MARK: Internal

    weak var delegate: Safari3BrowserViewControllerDelegate?

    override var title: String? {
        get { super.title }
        set {
            super.title = newValue
            delegate?.safari3Browser(
                self,
                titleDidChange: title
            )
        }
    }

    var url: URL? {
        get { _url }
        set {
            reload(
                using: newValue
            )
        }
    }

    var account: PersistenceAccount? {
        didSet {
            configuration.account = account
        }
    }

    var canGoBack: Bool {
        webView.canGoBack
    }

    var canGoForward: Bool {
        webView.canGoForward
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .jus_backgroundPrimary

        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(scrollView)
        scrollView.addSubview(webView)

        view.addSubview(errorView)
        view.addSubview(blurView)

        NSLayoutConstraint.activate({
            blurView.topAnchor.pin(to: view.topAnchor)
            blurView.pin(horizontally: view)
            blurView.bottomAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor)

            scrollView.pin(edges: view)
            errorView.pin(edges: view)
        })

        urlKeyValueObservation = webView.observe(
            \.url,
            options: [.new],
            changeHandler: { [weak self] _, change in
                guard change.oldValue != change.newValue
                else {
                    return
                }

                let url = change.newValue ?? nil
                self?.updateCurrentURL(url)
            }
        )

        loadingKeyValueObservation = webView.observe(
            \.isLoading,
            options: [.new],
            changeHandler: { [weak self] _, change in
                guard let self = self
                else {
                    return
                }

                self.delegate?.safari3Browser(
                    self,
                    didChangeLoading: change.newValue ?? false
                )
            }
        )

        if #available(iOS 15, *) {
            backgroundColorKeyValueObservation = webView.observe(
                \.underPageBackgroundColor,
                options: [.new],
                changeHandler: { [weak self] _, change in
                    guard let self = self
                    else {
                        return
                    }

                    self.scrollView.backgroundColor = change.newValue ?? .jus_backgroundPrimary
                }
            )
        }

        update(presentationState: presentationState, animated: false)

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .jus_textSecondary
        refreshControl.addTarget(
            self,
            action: #selector(refreshControlDidChange(_:)),
            for: .valueChanged
        )
        scrollView.refreshControl = refreshControl

        scrollView.bringSubviewToFront(refreshControl)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentInset = UIEdgeInsets(top: view.safeAreaInsets.top)
        scrollView.contentSize = CGSize(
            width: view.bounds.width,
            height: view.bounds.height - view.safeAreaInsets.top
        )

        webView.frame = CGRect(
            x: 0,
            y: -view.safeAreaInsets.top,
            width: view.bounds.width,
            height: view.bounds.height
        )
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        webView.customSafeAreaInsets = view.safeAreaInsets
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func reload() {
        webView.reload()
    }

    // MARK: Private

    private enum PresentationState {
        case error(error: Error, action: (() -> Void)?)
        case browsing
    }

    private lazy var configuration = WKWeb3Configuration().with({
        $0.dispatcher = self
    })

    private lazy var scrollView = UIScrollView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .jus_backgroundPrimary
        $0.contentInsetAdjustmentBehavior = .never
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    })

    private lazy var webView = Safari3WebView(frame: .zero, configuration: configuration).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.allowsBackForwardNavigationGestures = true
    })

    private let errorView = Safari3BrowserErrorView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })

    private var presentationState: PresentationState = .browsing
    private var urlKeyValueObservation: NSKeyValueObservation?
    private var loadingKeyValueObservation: NSKeyValueObservation?
    private var backgroundColorKeyValueObservation: NSKeyValueObservation?

    private var _url: URL?

    private func determinateTitle() {
        let defaultTitle = webView.url?.host
        webView.evaluateJavaScript(
            "document.title",
            completionHandler: { [weak self] object, _ in
                if let text = object as? String, !text.isEmpty {
                    self?.title = text
                } else {
                    self?.title = defaultTitle
                }
            }
        )
    }

    private func reload(
        using url: URL?
    ) {
        guard _url != url
        else {
            return
        }

        _url = url
        determinateTitle()

        guard let url = url
        else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func updateCurrentURL(
        _ url: URL?
    ) {
        _url = url
        delegate?.safari3Browser(
            self,
            didChangeURL: url
        )
    }

    private func update(
        presentationState: PresentationState,
        animated: Bool
    ) {
        let webViewOpacity = webView.layer.presentation()?.opacity ?? webView.layer.opacity
        webView.layer.removeAllAnimations()
        webView.layer.opacity = webViewOpacity

        let errorViewOpacity = errorView.layer.presentation()?.opacity ?? errorView.layer.opacity
        errorView.layer.removeAllAnimations()
        errorView.layer.opacity = errorViewOpacity

        switch self.presentationState {
        case .browsing:
            errorView.alpha = 0
        case .error:
            webView.alpha = 0
        }

        switch presentationState {
        case .browsing:
            break
        case let .error(error, action):
            errorView.model = .init(
                text: error.localizedDescription,
                action: action
            )
        }

        errorView.isHidden = false
        webView.isHidden = false

        let animations = {
            switch presentationState {
            case .browsing:
                self.errorView.alpha = 0
                self.webView.alpha = 1
            case .error:
                self.errorView.alpha = 1
                self.webView.alpha = 0
            }
        }

        let completion = { (_ finished: Bool) in
            switch presentationState {
            case .browsing:
                self.errorView.isHidden = true
                self.webView.isHidden = false
            case .error:
                self.webView.isHidden = true
                self.errorView.isHidden = false
            }
        }

        if animated {
            UIView.animate(
                withDuration: 0.42,
                delay: 0,
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }

        self.presentationState = presentationState
    }

    // MARK: Actions

    @objc
    private func refreshControlDidChange(_ sender: UIRefreshControl) {
        guard url != nil
        else {
            return
        }

        webView.reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.12, execute: {
            sender.endRefreshing()
        })
    }
}

// MARK: WKUIDelegate

extension Safari3BrowserViewController: WKUIDelegate {
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        } else if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }
}

// MARK: WKNavigationDelegate

extension Safari3BrowserViewController: WKNavigationDelegate {
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url,
              !Application.shared.openURLIfAvailable(url)
        else {
            return .cancel
        }

        let policy: WKNavigationActionPolicy
        if !url.absoluteString.hasPrefix("http://"),
           !url.absoluteString.hasPrefix("https://"),
           UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            policy = .cancel
        } else {
            // _WKNavigationActionPolicyAllowWithoutTryingAppLink
            if let _policy = WKNavigationActionPolicy(
                rawValue: WKNavigationActionPolicy.allow
                    .rawValue + 2
            ) {
                policy = _policy
            } else {
                policy = .allow
            }
        }

        switch policy {
        case .cancel:
            self.webView.updateUserAgetForURL(nil)
        default:
            self.webView.updateUserAgetForURL(navigationAction.request.url)
        }

        return policy
    }

    public func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        determinateTitle()
        update(
            presentationState: .browsing,
            animated: true
        )
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        determinateTitle()
    }

    public func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        var _error = error
        if _error.localizedDescription.isEmpty {
            _error = URLError(.unknown)
        }

        determinateTitle()
        update(
            presentationState: .error(
                error: _error,
                action: { [weak self] in
                    guard let self = self
                    else {
                        return
                    }

                    if self.webView.canGoBack {
                        self.webView.goBack()
                    } else {
                        self.delegate?.safari3Browser(
                            self,
                            wantsHomeWhileError: _error
                        )
                    }
                }
            ),
            animated: true
        )
    }
}

// MARK: WKWeb3EventDispatcher

extension Safari3BrowserViewController: WKWeb3EventDispatcher {
    var presentationContext: UIViewController? {
        self
    }

    func dispatch(
        name: String,
        detail: String
    ) async throws {
        try await webView.dispatch(
            name: name,
            detail: detail
        )
    }
}
