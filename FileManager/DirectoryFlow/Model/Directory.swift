//
//  Directory.swift
//  FileManager
//
//  Created by Egor Badaev on 09.04.2021.
//

import Foundation
import EBFoundation

enum DirectoryError: LocalizedError {
    case cannotDisplayObject
    
    var errorDescription: String? {
        switch self {
        case .cannotDisplayObject:
            return "Невозможно отобразить новую папку"
        }
    }
}

class Directory {

    //MARK: - Properties
    var objects: [FileSystemObject]
    private var url: URL
    
    // MARK: - Public
    static let rootUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK: - Public
    init(at url: URL) {
        print(type(of: self), #function)
        self.url = url
        objects = Directory.fileSystemObjects(at: url)
    }
    
    func createDirectory(_ name: String, completion: ((Result<Int,Error>) -> Void)?) {
        let newDirectoryUrl = url.appendingPathComponent(name)
        print(type(of: self), #function, newDirectoryUrl)
        do{
            try FileManager.default.createDirectory(at: newDirectoryUrl, withIntermediateDirectories: false, attributes: nil)
            let newIndex = try getNewObjectIndex()
            completion?(.success(newIndex))
        } catch let error {
            completion?(.failure(error))
        }
    }
    
    func deleteItem(at index: Int, completion: ((Result<Int, Error>) -> Void)?) {
        let url = objects[index].url
        do {
            try FileManager.default.removeItem(at: url)
            objects.remove(at: index)
            completion?(.success(index))
        } catch let error {
            completion?(.failure(error))
        }
    }
    
    func moveItem(from url: URL, completion: ((Result<Int, Error>) -> Void)?) {
        do {
            let newLocation = self.url.appendingPathComponent(url.lastPathComponent).avoidingDuplication()
            try FileManager.default.moveItem(at: url, to: newLocation)
            let newIndex = try getNewObjectIndex()
            completion?(.success(newIndex))
        } catch let error {
            completion?(.failure(error))
        }
    }
    
    //MARK: - Private
    private static func fileSystemObjects(at url: URL) -> [FileSystemObject] {
        var objects = [FileSystemObject]()
        
        if url != Directory.rootUrl {
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
        
        // Windows-style sorting: case-insensitive, directories first
        objects.sort { $0.name.lowercased() < $1.name.lowercased() }
        objects.sort { $0.type.rawValue < $1.type.rawValue }

        return objects
    }
    
    private func getNewObjectIndex() throws -> Int {
        let oldObjects = objects
        objects = Directory.fileSystemObjects(at: url)
        guard let newIndex = objects.indices.first(where: { ($0 == oldObjects.count) || (objects[$0].name != oldObjects[$0].name) }) else {
            throw DirectoryError.cannotDisplayObject
        }
        return newIndex
    }
}
