//
//  DriveViewModel.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//
import SwiftUI
import WebKit

class DriveViewModel: ObservableObject {
    @Published var tabs: [DriveTab] = []
    @Published var selectedTabId: UUID?
    @Published var isHomeLoaded = false
    @Published var loadingError: NetworkError?
    init() {
        // Home tab - always first
        let homeTab = DriveTab(
            title: "Home",
            url: URL(string: "https://drive.google.com/drive/u/0/my-drive")!,
            isLoading: true,
            isHome: true,
            favicon: "house.fill"
        )
        let photoTab = DriveTab(
            title: "Home",
            url: URL(string: "https://photos.google.com/?pli=1")!,
            isLoading: true,
            isHome: true,
            favicon: "house.fill"
        )
        tabs.append(homeTab)
        selectedTabId = homeTab.id
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .newTab, object: nil, queue: .main) { [weak self] _ in
            self?.addNewTab()
        }
    }
    
    func addNewTab(url: URL? = nil, title: String? = nil) {
        let newTab = DriveTab(
            title: title ?? "New Tab",
            url: url ?? URL(string: "https://drive.google.com/drive/u/0/my-drive")!,
            favicon: getFavicon(for: url)
        )
        tabs.append(newTab)
        selectedTabId = newTab.id
    }
    
    func closeTab(_ tab: DriveTab) {
        // Don't close home tab
        guard !tab.isHome, tabs.count > 1 else { return }
        
        if let index = tabs.firstIndex(of: tab) {
            tabs.remove(at: index)
            
            if selectedTabId == tab.id {
                if index < tabs.count {
                    selectedTabId = tabs[index].id
                } else if index > 0 {
                    selectedTabId = tabs[index - 1].id
                } else {
                    selectedTabId = tabs[0].id
                }
            }
        }
    }
    
    func updateTab(id: UUID, title: String? = nil, isLoading: Bool? = nil, url: URL? = nil) {
        if let index = tabs.firstIndex(where: { $0.id == id }) {
            if let title = title {
                tabs[index].title = title
            }
            if let isLoading = isLoading {
                tabs[index].isLoading = isLoading
            }
            if let url = url {
                tabs[index].favicon = getFavicon(for: url)
            }
        }
    }
    
    private func getFavicon(for url: URL?) -> String {
        guard let url = url else { return "doc.fill" }
        let urlString = url.absoluteString
        
        if urlString.contains("docs.google.com") {
            return "doc.text.fill"
        } else if urlString.contains("sheets.google.com") {
            return "tablecells.fill"
        } else if urlString.contains("slides.google.com") {
            return "square.stack.3d.down.right.fill"
        } else if urlString.contains("drive.google.com") {
            return "folder.fill"
        } else if urlString.contains("forms.google.com") {
            return "list.bullet.rectangle.fill"
        }
        return "doc.fill"
    }
}
