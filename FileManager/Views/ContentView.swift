//
//  ContentView.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DriveViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            TabBarView(viewModel: viewModel)
            
            if let selectedId = viewModel.selectedTabId,
               let selectedTab = viewModel.tabs.first(where: { $0.id == selectedId }) {
                DriveWebView(tab: selectedTab, viewModel: viewModel)
            }
        }
    }
}
