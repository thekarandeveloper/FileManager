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
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"
        
        let request = URLRequest(url: tab.url)
        webView.load(request)
        
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        if webView.url != tab.url {
            let request = URLRequest(url: tab.url)
            webView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: DriveWebView
        
        init(_ parent: DriveWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewModel.updateTab(id: parent.tab.id, isLoading: true)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.title") { result, error in
                if let title = result as? String, !title.isEmpty {
                    self.parent.viewModel.updateTab(
                        id: self.parent.tab.id,
                        title: title,
                        isLoading: false
                    )
                } else {
                    self.parent.viewModel.updateTab(id: self.parent.tab.id, isLoading: false)
                }
            }
            
            if let url = webView.url {
                parent.viewModel.updateTab(id: parent.tab.id, url: url)
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.targetFrame?.request.url,
               navigationAction.targetFrame?.isMainFrame == false,
               url.absoluteString.contains("docs.google.com") ||
               url.absoluteString.contains("sheets.google.com") ||
               url.absoluteString.contains("slides.google.com") {
                
                DispatchQueue.main.async {
                    self.parent.viewModel.addNewTab(url: url)
                }
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
    }
}
