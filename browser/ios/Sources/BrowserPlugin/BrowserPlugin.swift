import Foundation
import Capacitor
import WebKit

@objc(CAPBrowserPlugin)
public class CAPBrowserPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CAPBrowserPlugin"
    public let jsName = "Browser"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "open", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "close", returnType: CAPPluginReturnPromise),
    ]
    private let implementation = Browser()

    @objc func open(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url"), let url = URL(string: urlString) else {
            call.reject("Must provide a valid URL to open")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let webView = self?.implementation.prepare(for: url) {
                webView.frame = self?.bridge?.viewController?.view.bounds ?? CGRect.zero
                webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self?.bridge?.viewController?.view.addSubview(webView)
            }
        }

        implementation.browserEventDidOccur = { [weak self] (event) in
            self?.notifyListeners(event.listenerEvent, data: nil)
        }

        call.resolve()
    }

    @objc func close(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            self?.implementation.cleanup()
            call.resolve()
        }
    }
}

private extension BrowserEvent {
    var listenerEvent: String {
        switch self {
        case .loaded:
            return "browserPageLoaded"
        case .finished:
            return "browserFinished"
        }
    }
}
