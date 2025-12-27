//
//  DriveWebView.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//

import SwiftUI
import WebKit

struct DriveWebView: NSViewRepresentable {
    let tab: DriveTab
    @ObservedObject var viewModel: DriveViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        config.websiteDataStore = .default()
        config.processPool = WKProcessPool()
        
        // Important: Enable modern features
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.preferences.setValue(true, forKey: "javaScriptCanAccessClipboard")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        // Updated User Agent - Important for Google Sign In
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
        
        if #available(macOS 13.3, *) {
            webView.isInspectable = true
        }
        
        context.coordinator.currentTabId = tab.id
        
        let request = URLRequest(url: tab.url)
        webView.load(request)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Do nothing to prevent reloading
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: DriveWebView
        var currentTabId: UUID?
        
        init(_ parent: DriveWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            guard let tabId = currentTabId else { return }
            DispatchQueue.main.async {
                self.parent.viewModel.updateTab(id: tabId, isLoading: true)
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            guard let tabId = currentTabId else { return }
            
            webView.evaluateJavaScript("document.title") { result, error in
                DispatchQueue.main.async {
                    let title = (result as? String) ?? "Google Drive"
                    self.parent.viewModel.updateTab(
                        id: tabId,
                        title: title,
                        isLoading: false,
                        url: webView.url
                    )
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            guard let tabId = currentTabId else { return }
            DispatchQueue.main.async {
                self.parent.viewModel.updateTab(id: tabId, isLoading: false)
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            guard let tabId = currentTabId else { return }
            DispatchQueue.main.async {
                self.parent.viewModel.updateTab(id: tabId, isLoading: false)
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Handle downloads
            if let url = navigationAction.request.url,
               navigationAction.shouldPerformDownload {
                let fileName = url.lastPathComponent
                DownloadManager.shared.startDownload(url: url, fileName: fileName)
                decisionHandler(.cancel)
                return
            }
            
            // Open links in new tab
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url {
                    DispatchQueue.main.async {
                        self.parent.viewModel.addNewTab(url: url, title: url.lastPathComponent)
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            // Check if it's a download
            if let response = navigationResponse.response as? HTTPURLResponse {
                let contentType = response.value(forHTTPHeaderField: "Content-Type") ?? ""
                let contentDisposition = response.value(forHTTPHeaderField: "Content-Disposition") ?? ""
                
                // Check if it should be downloaded
                if contentDisposition.contains("attachment") ||
                   !contentType.contains("text/html") &&
                   !contentType.contains("application/json") {
                    
                    if let url = response.url {
                        let fileName = url.lastPathComponent
                        DownloadManager.shared.startDownload(url: url, fileName: fileName)
                        decisionHandler(.cancel)
                        return
                    }
                }
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                DispatchQueue.main.async {
                    self.parent.viewModel.addNewTab(url: url, title: url.lastPathComponent)
                }
            }
            return nil
        }
        
        // Handle JavaScript alerts, confirms, prompts
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = NSAlert()
            alert.messageText = "Alert"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.runModal()
            completionHandler()
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = NSAlert()
            alert.messageText = "Confirm"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let response = alert.runModal()
            completionHandler(response == .alertFirstButtonReturn)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alert = NSAlert()
            alert.messageText = "Input"
            alert.informativeText = prompt
            
            let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            textField.stringValue = defaultText ?? ""
            alert.accessoryView = textField
            
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                completionHandler(textField.stringValue)
            } else {
                completionHandler(nil)
            }
        }
    }
}
