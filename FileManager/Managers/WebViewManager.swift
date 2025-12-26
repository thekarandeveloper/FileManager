//
//  WebViewManager.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//

import WebKit

class WebViewManager {
    static let shared = WebViewManager()
    
    private init() {
        configureWebKit()
    }
    
    private func configureWebKit() {
        let dataStore = WKWebsiteDataStore.default()
        let config = WKWebViewConfiguration()
        config.websiteDataStore = dataStore
    }
    
    func clearCache() {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: date) {
            print("Cache cleared")
        }
    }
}
