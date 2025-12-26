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
    
    init() {
        addNewTab()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .newTab, object: nil, queue: .main) { [weak self] _ in
            self?.addNewTab()
        }
    }
    
    func addNewTab(url: URL? = nil) {
        let newTab = DriveTab(url: url ?? URL(string: "https://drive.google.com")!)
        tabs.append(newTab)
        selectedTabId = newTab.id
    }
    
    func closeTab(_ tab: DriveTab) {
        guard tabs.count > 1 else { return }
        
        if let index = tabs.firstIndex(of: tab) {
            tabs.remove(at: index)
            
            if selectedTabId == tab.id {
                if index < tabs.count {
                    selectedTabId = tabs[index].id
                } else if index > 0 {
                    selectedTabId = tabs[index - 1].id
                }
            }
        }
    }
    
    func updateTab(id: UUID, title: String? = nil, url: URL? = nil, isLoading: Bool? = nil) {
        if let index = tabs.firstIndex(where: { $0.id == id }) {
            if let title = title {
                tabs[index].title = title
            }
            if let url = url {
                tabs[index].url = url
            }
            if let isLoading = isLoading {
                tabs[index].isLoading = isLoading
            }
        }
    }
}
