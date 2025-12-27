//
//  TabBarView.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: DriveViewModel
    @ObservedObject var downloadManager = DownloadManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // Fixed Home Button (Icon only)
            if let homeTab = viewModel.tabs.first(where: { $0.isHome }) {
                HomeButton(
                    isSelected: viewModel.selectedTabId == homeTab.id,
                    onSelect: { viewModel.selectedTabId = homeTab.id }
                )
            }
            
            // Vertical divider
            Rectangle()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 1, height: 28)
                .padding(.horizontal, 8)
            
            // Scrollable Tabs (all except home)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(viewModel.tabs.filter { !$0.isHome }) { tab in
                        ModernTabItem(
                            tab: tab,
                            isSelected: viewModel.selectedTabId == tab.id,
                            onSelect: { viewModel.selectedTabId = tab.id },
                            onClose: { viewModel.closeTab(tab) }
                        )
                    }
                }
                .padding(.trailing, 8)
            }
            
            Spacer()
            
            // Download button
            Button(action: { downloadManager.isDownloadPanelOpen.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 16))
                    
                    if downloadManager.downloads.filter({ $0.status == .downloading }).count > 0 {
                        Text("\(downloadManager.downloads.filter({ $0.status == .downloading }).count)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            
        }
        .frame(height: 44)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.secondary.opacity(0.2)),
            alignment: .bottom
        )
    }
}

struct HomeButton: View {
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onSelect) {
            Image(systemName: "house.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 28, height: 28)
                .background(Color.secondary.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .onHover { isHovered = $0 }
    }
}

struct ModernTabItem: View {
    let tab: DriveTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            if tab.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: tab.favicon)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            
            // Title
            Text(tab.title)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                .lineLimit(1)
                .frame(maxWidth: 180)
            
            // Close button (only show on hover)
            if isHovered {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 16, height: 16)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.1) : (isHovered ? Color.secondary.opacity(0.08) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { isHovered = $0 }
    }
}
