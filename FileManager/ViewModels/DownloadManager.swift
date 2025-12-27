//
//  DownloadManager.swift
//  FileManager
//
//  Created by swipe mac on 27/12/25.
//


import SwiftUI
import Combine

class DownloadManager: NSObject, ObservableObject {
    @Published var downloads: [DownloadItem] = []
    @Published var isDownloadPanelOpen = false
    
    static let shared = DownloadManager()
    
    private var downloadTasks: [UUID: URLSessionDownloadTask] = [:]
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    override private init() {
        super.init()
    }
    
    func startDownload(url: URL, fileName: String) {
        let downloadItem = DownloadItem(
            fileName: fileName,
            url: url,
            status: .downloading
        )
        
        DispatchQueue.main.async {
            self.downloads.insert(downloadItem, at: 0)
            self.isDownloadPanelOpen = true
        }
        
        let task = urlSession.downloadTask(with: url)
        downloadTasks[downloadItem.id] = task
        task.resume()
    }
    
    func pauseDownload(_ item: DownloadItem) {
        guard let task = downloadTasks[item.id] else { return }
        task.cancel()
        
        if let index = downloads.firstIndex(where: { $0.id == item.id }) {
            downloads[index].status = .paused
        }
    }
    
    func resumeDownload(_ item: DownloadItem) {
        let task = urlSession.downloadTask(with: item.url)
        downloadTasks[item.id] = task
        task.resume()
        
        if let index = downloads.firstIndex(where: { $0.id == item.id }) {
            downloads[index].status = .downloading
        }
    }
    
    func cancelDownload(_ item: DownloadItem) {
        guard let task = downloadTasks[item.id] else { return }
        task.cancel()
        downloadTasks.removeValue(forKey: item.id)
        
        downloads.removeAll { $0.id == item.id }
    }
    
    func openDownload(_ item: DownloadItem) {
        guard let destination = item.destination else { return }
        NSWorkspace.shared.open(destination)
    }
    
    func showInFinder(_ item: DownloadItem) {
        guard let destination = item.destination else { return }
        NSWorkspace.shared.activateFileViewerSelecting([destination])
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let downloadId = downloadTasks.first(where: { $0.value == downloadTask })?.key,
              let index = downloads.firstIndex(where: { $0.id == downloadId }) else { return }
        
        let fileName = downloads[index].fileName
        let destinationURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        
        try? FileManager.default.removeItem(at: destinationURL)
        try? FileManager.default.moveItem(at: location, to: destinationURL)
        
        DispatchQueue.main.async {
            self.downloads[index].status = .completed
            self.downloads[index].destination = destinationURL
            self.downloads[index].progress = 1.0
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let downloadId = downloadTasks.first(where: { $0.value == downloadTask })?.key,
              let index = downloads.firstIndex(where: { $0.id == downloadId }) else { return }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.downloads[index].progress = progress
            self.downloads[index].downloadedSize = totalBytesWritten
            self.downloads[index].fileSize = totalBytesExpectedToWrite
            
            // Calculate speed and time
            let speed = self.formatBytes(bytesWritten)
            let remaining = totalBytesExpectedToWrite - totalBytesWritten
            self.downloads[index].speed = "\(speed)/s"
            
            if bytesWritten > 0 {
                let timeRemaining = Double(remaining) / Double(bytesWritten)
                self.downloads[index].timeRemaining = self.formatTime(timeRemaining)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error,
              let downloadId = downloadTasks.first(where: { $0.value == task })?.key,
              let index = downloads.firstIndex(where: { $0.id == downloadId }) else { return }
        
        DispatchQueue.main.async {
            self.downloads[index].status = .failed
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        if seconds < 60 {
            return "\(Int(seconds)) sec"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60)) min"
        } else {
            return "\(Int(seconds / 3600)) hr"
        }
    }
}