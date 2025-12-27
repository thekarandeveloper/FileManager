//
//  DownloadPanel.swift
//  FileManager
//
//  Created by swipe mac on 27/12/25.
//


import SwiftUI

struct DownloadPanel: View {
    @ObservedObject var downloadManager: DownloadManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                
                Text("Downloads")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { downloadManager.isDownloadPanelOpen = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Downloads list
            if downloadManager.downloads.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.doc")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No downloads yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(downloadManager.downloads) { download in
                            DownloadItemView(item: download, downloadManager: downloadManager)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct DownloadItemView: View {
    let item: DownloadItem
    @ObservedObject var downloadManager: DownloadManager
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // File icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 18))
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // File name
                    Text(item.fileName)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                    
                    // Status info
                    HStack(spacing: 8) {
                        Text(statusText)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        if item.status == .downloading {
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(item.speed)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                if isHovered || item.status == .downloading {
                    HStack(spacing: 8) {
                        if item.status == .completed {
                            Button(action: { downloadManager.showInFinder(item) }) {
                                Image(systemName: "folder")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { downloadManager.openDownload(item) }) {
                                Image(systemName: "arrow.up.forward.square")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        } else if item.status == .downloading {
                            Button(action: { downloadManager.pauseDownload(item) }) {
                                Image(systemName: "pause.fill")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        } else if item.status == .paused {
                            Button(action: { downloadManager.resumeDownload(item) }) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button(action: { downloadManager.cancelDownload(item) }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            if item.status == .downloading || item.status == .paused {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.1))
                        
                        Rectangle()
                            .fill(statusColor)
                            .frame(width: geometry.size.width * item.progress)
                    }
                }
                .frame(height: 4)
                .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovered ? Color.secondary.opacity(0.05) : Color.clear)
        )
        .onHover { isHovered = $0 }
    }
    
    private var statusColor: Color {
        switch item.status {
        case .downloading: return .blue
        case .paused: return .orange
        case .completed: return .green
        case .failed: return .red
        }
    }
    
    private var statusIcon: String {
        switch item.status {
        case .downloading: return "arrow.down.circle.fill"
        case .paused: return "pause.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    private var statusText: String {
        switch item.status {
        case .downloading:
            let downloaded = ByteCountFormatter.string(fromByteCount: item.downloadedSize, countStyle: .file)
            let total = ByteCountFormatter.string(fromByteCount: item.fileSize, countStyle: .file)
            return "\(downloaded) / \(total)"
        case .paused: return "Paused"
        case .completed:
            let size = ByteCountFormatter.string(fromByteCount: item.fileSize, countStyle: .file)
            return "Completed • \(size)"
        case .failed: return "Failed"
        }
    }
}