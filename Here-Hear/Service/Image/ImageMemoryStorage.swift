//
//  ImageMemoryStorage.swift
//  Here-Hear
//
//  Created by Martin on 3/9/24.
//

import UIKit

protocol ImageMemoryStorageProtocol {
    func image(for key: String) -> UIImage?
    func store(for key: String, image: UIImage)
}

final class ImageMemoryStorage: ImageMemoryStorageProtocol {
    private let cache = NSCache<NSString, UIImage>()
    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func store(for key: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: key))
    }
}
