//
//  ContentView.swift
//  FileManager
//
//  Updated on 27/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DriveViewModel()
    @StateObject private var downloadManager = DownloadManager.shared
    @State private var isLoading = true
    @State private var isRetrying = false
    
    var body: some View {
        ZStack {
            // Main content
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
            .blur(radius: (isLoading || isRetrying) ? 3 : 0)
            .scaleEffect((isLoading || isRetrying) ? 0.95 : 1)
            
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
            
            // Error overlay
            if let error = viewModel.loadingError, !isRetrying {
                ErrorView(error: error) {
                    handleRetry()
                }
                .transition(.opacity)
            }
            
            // Loading overlay
            if isLoading || isRetrying {
                LoadingView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isLoading)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isRetrying)
        .animation(.easeInOut(duration: 0.3), value: viewModel.loadingError)
        .onChange(of: viewModel.isHomeLoaded) { _, loaded in
            if loaded {
                withAnimation(.easeOut(duration: 0.8)) {
                    isLoading = false
                    isRetrying = false
                }
            }
        }
        .onChange(of: viewModel.loadingError) { _, error in
            if error != nil {
                withAnimation(.easeOut(duration: 0.4)) {
                    isLoading = false
                    isRetrying = false
                }
            }
        }
    }
    
    private func handleRetry() {
        // Reset and show loading
        isRetrying = true
        viewModel.loadingError = nil
        viewModel.isHomeLoaded = false
        
        // Ensure minimum 2 seconds of loading
        let retryStartTime = Date()
        
        // Reload WebView
        guard let selectedId = viewModel.selectedTabId else { return }
        
        NotificationCenter.default.post(
            name: Notification.Name("reloadWebView"),
            object: nil,
            userInfo: ["tabId": selectedId, "startTime": retryStartTime]
        )
    }
}
