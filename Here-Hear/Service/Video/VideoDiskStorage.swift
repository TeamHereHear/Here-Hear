//
//  VideoDiskStorage.swift
//  Here-Hear
//
//  Created by Martin on 4/22/24.
//

import Foundation

protocol VideoDiskStorageProtocol {
    func video(for key: String) -> URL?
    func store(for key: String, videoData: Data) throws
}

class VideoDiskStorage: VideoDiskStorageProtocol {
    private let fileManager: FileManager
    private let directoryUrl: URL
    
    init(
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.directoryUrl = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathExtension("VideoCache")
        
        createDirectory()
    }
    
    private func createDirectory() {
        guard !fileExists(atUrl: directoryUrl) else { return }
            
        do {
            try fileManager.createDirectory(
                at: directoryUrl,
                withIntermediateDirectories: true
            )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func fileExists(atUrl url: URL) -> Bool {
        let fileExists: Bool = if #available(iOS 16.0, *) {
             fileManager.fileExists(atPath: url.path())
        } else {
            fileManager.fileExists(atPath: url.path)
        }
        return fileExists
    }
    
    private func cacheFileUrl(for key: String) -> URL {
        let fileName = sha256(key)
        return directoryUrl.appendingPathComponent(fileName, isDirectory: false)
    }
    
    func video(for key: String) -> URL? {
        let fileUrl: URL = cacheFileUrl(for: key)
        
        guard fileExists(atUrl: fileUrl) else {
            return nil
        }
        
        return fileUrl
    }
    
    func store(for key: String, videoData: Data) throws {
        let fileUrl: URL = cacheFileUrl(for: key)
        try videoData.write(to: fileUrl)
    }

}
