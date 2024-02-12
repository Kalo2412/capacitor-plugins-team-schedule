import Foundation
import WebKit

@objc public enum BrowserEvent: Int {
    case loaded
    case finished
}

@objc public class Browser: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    public typealias BrowserEventCallback = (BrowserEvent) -> Void

    @objc public var browserEventDidOccur: BrowserEventCallback?

    @objc public func prepare(for url: URL) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        self.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    @objc public func cleanup() {
        webView?.removeFromSuperview()
        webView = nil
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        browserEventDidOccur?(.finished)
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        browserEventDidOccur?(.loaded)
    }
}