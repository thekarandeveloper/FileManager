//
//  DriveTab.swift
//  FileManager
//
//  Created by Karan Kumar on 26/12/25.
//
import Foundation

struct DriveTab: Identifiable, Equatable {
    let id: UUID
    var title: String
    var url: URL
    var isLoading: Bool
    var isHome: Bool
    var favicon: String
    
    init(id: UUID = UUID(),
         title: String = "Google Drive",
         url: URL = URL(string: "https://drive.google.com/drive/u/0/my-drive")!,
         isLoading: Bool = true,
         isHome: Bool = false,
         favicon: String = "folder.fill") {
        self.id = id
        self.title = title
        self.url = url
        self.isLoading = isLoading
        self.isHome = isHome
        self.favicon = favicon
    }
    
    static func == (lhs: DriveTab, rhs: DriveTab) -> Bool {
        lhs.id == rhs.id
    }
}
