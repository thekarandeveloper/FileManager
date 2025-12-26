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
    
    init(id: UUID = UUID(), title: String = "Google Drive", url: URL = URL(string: "https://drive.google.com")!, isLoading: Bool = true) {
        self.id = id
        self.title = title
        self.url = url
        self.isLoading = isLoading
    }
    
    static func == (lhs: DriveTab, rhs: DriveTab) -> Bool {
        lhs.id == rhs.id
    }
}
