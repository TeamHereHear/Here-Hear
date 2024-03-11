//
//  ImageService.swift
//  Here-Hear
//
//  Created by Martin on 3/9/24.
//

import UIKit

enum ImageServiceError: Error {
    case invalidUrl
    case failedToGetDiskCachedImage
    case failedToFetch
    
    var toServiceError: ServiceError {
        .error(self)
    }
}

protocol ImageServiceProtocol {
    func image(forUrlPath path: String) async throws -> UIImage?
}

final class ImageService: ImageServiceProtocol {
    private let memoryStorage: ImageMemoryStorageProtocol
    private let diskStorage: ImageDiskStorageProtocol
    
    init(
        memoryStorage: ImageMemoryStorageProtocol = ImageMemoryStorage(),
        diskStorage: ImageDiskStorageProtocol = ImageDiskStorage()
    ) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
    }
    
    func image(forUrlPath path: String) async throws -> UIImage? {
        if let memoryCachedImage = memoryStorage.image(for: path) {
            return memoryCachedImage
        }
        
        do {
            let diskCachedImage = try diskStorage.image(for: path)
            
            if let diskCachedImage {
                store(forPath: path, image: diskCachedImage, alsoInDisk: false)
                return diskCachedImage
            }
        } catch {
            throw ImageServiceError.failedToGetDiskCachedImage.toServiceError
        }
        
        guard let url = URL(string: path) else {
            throw ImageServiceError.invalidUrl.toServiceError
        }
        
        do {
            let response = try await URLSession.shared.data(from: url)
            
            if let remoteImage = UIImage(data: response.0) {
                store(forPath: path, image: remoteImage, alsoInDisk: true)
                return remoteImage
            }
        } catch {
            throw ImageServiceError.failedToFetch.toServiceError
        }
        
        return nil
    }
    
    private func store(forPath path: String, image: UIImage, alsoInDisk storeInDisk: Bool) {
        memoryStorage.store(for: path, image: image)
        
        if storeInDisk {
            #warning("TODO: 품질을 얼마만큼으로 저장할지 정해야한다.")
            try? diskStorage.store(for: path, image: image, compressionQuality: 0.8)
        }
    }
}

final class StubImageService: ImageServiceProtocol {
    func image(forUrlPath path: String) async throws -> UIImage? {
        nil
    }
}
