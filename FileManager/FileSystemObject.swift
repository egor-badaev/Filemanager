//
//  FileSystemObject.swift
//  FileManager
//
//  Created by Egor Badaev on 09.04.2021.
//

import Foundation

enum ContentType {
    case directory
    case file
    case up
}

struct FileSystemObject {
    var type: ContentType
    var name: String
    var url: URL
}
