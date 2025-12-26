//
//  WKWebView+Extensions.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//

import WebKit

extension WKWebView {
    func loadDrive() {
        if let url = URL(string: "https://drive.google.com/drive/u/0/home") {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}
