//
//  TabBarView.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: DriveViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(viewModel.tabs) { tab in
                        TabItemView(
                            tab: tab,
                            isSelected: viewModel.selectedTabId == tab.id,
                            onSelect: { viewModel.selectedTabId = tab.id },
                            onClose: { viewModel.closeTab(tab) }
                        )
                    }
                }
            }
            
            Button(action: { viewModel.addNewTab() }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 30, height: 32)
            }
            .buttonStyle(.plain)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(height: 32)
    }
}

struct TabItemView: View {
    let tab: DriveTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 8) {
            if tab.isLoading {
                ProgressView()
                    .scaleEffect(0.5)
                    .frame(width: 12, height: 12)
            } else {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Text(tab.title)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(maxWidth: 150)
            
            if isHovered {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(isSelected ? Color(NSColor.selectedContentBackgroundColor) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { isHovered = $0 }
    }
}
