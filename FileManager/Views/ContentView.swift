//
//  ContentView.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DriveViewModel()
    @StateObject private var downloadManager = DownloadManager.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabBarView(viewModel: viewModel)
                
                ZStack {
                    ForEach(viewModel.tabs) { tab in
                        DriveWebView(tab: tab, viewModel: viewModel)
                            .opacity(viewModel.selectedTabId == tab.id ? 1 : 0)
                            .id(tab.id)
                    }
                }
            }
            
            // Download panel
            if downloadManager.isDownloadPanelOpen {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        downloadManager.isDownloadPanelOpen = false
                    }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        DownloadPanel(downloadManager: downloadManager)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                            .padding()
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: downloadManager.isDownloadPanelOpen)
    }
}
