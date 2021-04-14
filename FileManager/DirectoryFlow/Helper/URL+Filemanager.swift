//
//  URL+Filemanager.swift
//  FileManager
//
//  Created by Egor Badaev on 10.04.2021.
//

import Foundation

extension URL {
    /**
     A function to find suitable location for a file. If file with the same name already exists, it appends `" (1)"` to the end of the filename, and if that file also exists it keeps growing the number until it finds an available name
     
     - returns: `URL` available to write to safely
     */
    func avoidingDuplication() -> URL {
        if FileManager.default.fileExists(atPath: self.path) {
            
            var filename = self.deletingPathExtension().lastPathComponent
            let fileExtension = self.pathExtension
            let baseUrl = self.deletingLastPathComponent()
            
            let regexPattern = " \\((\\d+)\\)$"
            let regex = NSRegularExpression(regexPattern)
            let capturedGroups = regex.matchedGroups(in: filename)
            
            if let currentNumberString = capturedGroups.last,
               let currentNumber = Int(currentNumberString) {
                filename = filename.replacingOccurrences(of: regexPattern, with: " (\(currentNumber + 1))", options: .regularExpression)
            } else {
                filename = "\(filename) (1)"
            }
            
            let alternativeLocation = baseUrl.appendingPathComponent(filename).appendingPathExtension(fileExtension)
            return alternativeLocation.avoidingDuplication()
        }
        return self
    }
}
