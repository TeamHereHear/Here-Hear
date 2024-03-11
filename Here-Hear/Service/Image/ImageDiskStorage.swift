//
//  ImageDiskStorage.swift
//  Here-Hear
//
//  Created by Martin on 3/9/24.
//

import UIKit

protocol ImageDiskStorageProtocol {
    func image(for key: String) throws -> UIImage?
    func store(for key: String, image: UIImage, compressionQuality: CGFloat) throws
}

final class ImageDiskStorage: ImageDiskStorageProtocol {

    private let fileManager: FileManager
    private let directoryUrl: URL
    
    init(
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        self.directoryUrl = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathExtension("ImageCache")
        
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
    
    func image(for key: String) throws -> UIImage? {
        let fileUrl: URL = cacheFileUrl(for: key)
        
        guard fileExists(atUrl: fileUrl) else { return nil }
        
        let data = try Data(contentsOf: fileUrl)
        
        return UIImage(data: data)
    }
    
    func store(for key: String, image: UIImage, compressionQuality: CGFloat = 0.9) throws {
        let fileUrl: URL = cacheFileUrl(for: key)
        
        let data: Data? = image.jpegData(compressionQuality: compressionQuality)
        try data?.write(to: fileUrl)
    }
}
