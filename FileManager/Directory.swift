//
//  Directory.swift
//  FileManager
//
//  Created by Egor Badaev on 09.04.2021.
//

import Foundation

class Directory {

    //MARK: - Properties
    var objects: [FileSystemObject]
    private var url: URL
    
    // MARK: - Public
    static let defaultUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK: - Private
    init(at url: URL) {
        print(type(of: self), #function)
        self.url = url
        objects = Directory.fileSystemObjects(at: url)
    }
    
    private static func fileSystemObjects(at url: URL) -> [FileSystemObject] {
        var objects = [FileSystemObject]()
        
        if url != Directory.defaultUrl {
            objects.append(FileSystemObject(type: .up, name: "..", url: url.deletingLastPathComponent()))
        }
        
        let resourceKeys : [URLResourceKey] = [.isDirectoryKey, .isRegularFileKey]
        if let documentsEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants], errorHandler: nil) {
            for case let fileURL as URL in documentsEnumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                   let isDirectory = resourceValues.isDirectory,
                   let isRegularFile = resourceValues.isRegularFile {
                    var type: ContentType? = nil
                    if isDirectory {
                        type = .directory
                    } else if isRegularFile {
                        type = .file
                    }
                    if let contentType = type {
                        let fsObject = FileSystemObject(type: contentType, name: fileURL.lastPathComponent, url: fileURL)
                        objects.append(fsObject)
                    }
                }
            }
        }
        
        // TODO: Sort files and directories by type and name
        return objects
    }
    
    
    
}
