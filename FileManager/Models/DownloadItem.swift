//
//  DownloadItem.swift
//  FileManager
//
//  Created by swipe mac on 27/12/25.
//


import Foundation

struct DownloadItem: Identifiable {
    let id: UUID
    var fileName: String
    var fileSize: Int64
    var downloadedSize: Int64
    var progress: Double
    var url: URL
    var destination: URL?
    var status: DownloadStatus
    var speed: String
    var timeRemaining: String
    
    init(id: UUID = UUID(),
         fileName: String,
         fileSize: Int64 = 0,
         downloadedSize: Int64 = 0,
         progress: Double = 0,
         url: URL,
         destination: URL? = nil,
         status: DownloadStatus = .downloading,
         speed: String = "0 KB/s",
         timeRemaining: String = "Calculating...") {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.downloadedSize = downloadedSize
        self.progress = progress
        self.url = url
        self.destination = destination
        self.status = status
        self.speed = speed
        self.timeRemaining = timeRemaining
    }
    
    enum DownloadStatus {
        case downloading
        case paused
        case completed
        case failed
    }
}