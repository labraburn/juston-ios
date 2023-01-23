//
//  Created by Anton Spivak
//

import ObjectiveC.runtime
import WebKit

// MARK: - WKWeb3URLSchemeHandler

//    in1.ton.org port 8080
//    in2.ton.org port 8080
//    in3.ton.org port 8080

class WKWeb3URLSchemeHandler: NSObject, WKURLSchemeHandler {
    // MARK: Internal

    static func hijack() {
        let origin = class_getClassMethod(
            WKWebView.self,
            #selector(WKWebView.handlesURLScheme(_:))
        )

        let hijacked = class_getClassMethod(
            WKWebView.self,
            #selector(WKWebView._sw_handlesURLScheme(_:))
        )

        guard let origin, let hijacked
        else {
            return
        }

        method_exchangeImplementations(origin, hijacked)
    }

    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url
        else {
            return
        }

        guard let host = url.host,
              host.hasSuffix(".ton") || host.hasSuffix(".adnl")
        else {
            handleDefaultURLRequest(urlSchemeTask)
            return
        }

        handleProxyURLRequest(urlSchemeTask)
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
//        urlSchemeTask.didReceive(URLError(.cancelled))

//        tasks[urlSchemeTask.request]?.cancel()
        tasks.removeValue(forKey: urlSchemeTask.request)
    }

    // MARK: Fileprivate

    fileprivate static var schemes = ["http", "https"]

    // MARK: Private

    private var tasks: [URLRequest: URLSessionDataTask] = [:]

    private lazy var configuration: URLSessionConfiguration = {
//        let kCFNetworkProxiesHTTPSEnable = "HTTPSEnable"
//        let kCFNetworkProxiesHTTPSProxy = "HTTPSProxy"
//        let kCFNetworkProxiesHTTPSPort = "HTTPSPort"
        let configuration = URLSessionConfiguration.default
        configuration.connectionProxyDictionary = [
            kCFNetworkProxiesHTTPEnable: true,
            kCFNetworkProxiesHTTPProxy: "in1.ton.org",
            kCFNetworkProxiesHTTPPort: 8080,
        ]

        return configuration
    }()

    private lazy var defaultURLSession: URLSession = {
        let session = URLSession(configuration: .default)
        return session
    }()

    private lazy var proxyURLSession: URLSession = {
        let session = URLSession(configuration: configuration)
        return session
    }()

    private func handleProxyURLRequest(_ urlSchemeTask: WKURLSchemeTask) {
        let task = proxyURLSession.dataTask(
            with: urlSchemeTask.request,
            completionHandler: { [weak urlSchemeTask, weak self] data, response, error in
                guard let self,
                      let urlSchemeTask
                else {
                    urlSchemeTask?.didFailWithError(URLError(.cancelled))
                    return
                }

                self.handleURLSessionDataTask(
                    for: urlSchemeTask,
                    data: data,
                    response: response,
                    error: error
                )
            }
        )

        tasks[urlSchemeTask.request] = task
        task.resume()
    }

    private func handleDefaultURLRequest(_ urlSchemeTask: WKURLSchemeTask) {
        if let scheme = urlSchemeTask.request.url?.scheme,
           scheme == "http"
        {
            urlSchemeTask.didFailWithError(
                URLError(.appTransportSecurityRequiresSecureConnection)
            )

            return
        }

        let task = defaultURLSession.dataTask(
            with: urlSchemeTask.request,
            completionHandler: { [weak urlSchemeTask, weak self] data, response, error in
                guard let self,
                      let urlSchemeTask
                else {
                    urlSchemeTask?.didFailWithError(URLError(.cancelled))
                    return
                }

                self.handleURLSessionDataTask(
                    for: urlSchemeTask,
                    data: data,
                    response: response,
                    error: error
                )
            }
        )

        tasks[urlSchemeTask.request] = task
        task.resume()
    }

    private func handleURLSessionDataTask(
        for urlSchemeTask: WKURLSchemeTask,
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) {
        if let error = error, error._code != NSURLErrorCancelled {
            urlSchemeTask.didFailWithError(error)
            tasks.removeValue(forKey: urlSchemeTask.request)
        } else {
            if let response = response {
                urlSchemeTask.didReceive(response)
            }
            if let data = data {
                urlSchemeTask.didReceive(data)
            }

            urlSchemeTask.didFinish()
            tasks.removeValue(forKey: urlSchemeTask.request)
        }
    }
}

extension WKWebViewConfiguration {
    func add(_ handler: WKWeb3URLSchemeHandler) {
        WKWeb3URLSchemeHandler.schemes.forEach({
            setURLSchemeHandler(handler, forURLScheme: $0)
        })
    }
}

private extension WKWebView {
    @objc(_sw_handlesURLScheme:)
    static func _sw_handlesURLScheme(_ urlScheme: String) -> Bool {
        // Help to avoid fatalError when we try to add custom url scheme
        // for 'http'/'https'
        guard !WKWeb3URLSchemeHandler.schemes.contains(urlScheme)
        else {
            return false
        }

        return handlesURLScheme(urlScheme)
    }
}
