//
//  ImageUploadService.swift
//  Here-Hear
//
//  Created by Martin on 3/7/24.
//

import SwiftUI
import Combine

import FirebaseStorage

enum ImageUploadServiceError: Error {
    case encodingError
    case nilSelf
    case error(Error)
}

protocol ImageUploadServiceProtocol {
    func upload(
        _ image: UIImage,
        compressionQuality: CGFloat,
        path: String
    ) -> AnyPublisher<Void, ServiceError>
}

class ImageUploadService: ImageUploadServiceProtocol {
    private let storageRef = Storage.storage().reference()
    
    func upload(_ image: UIImage, compressionQuality: CGFloat = 0.5, path: String) -> AnyPublisher<Void, ServiceError> {
        Future<Void, ImageUploadServiceError> { [weak self] promise in
            guard let self else {
                promise(.failure(.nilSelf))
                return
            }
            guard let data = image.jpegData(compressionQuality: compressionQuality) else {
                promise(.failure(.encodingError))
                return
            }
            
            self.storageRef.child(path).putData(data) { _, error in
                if let error {
                    promise(.failure(.error(error)))
                    return
                }
            }
            
            promise(.success(()))
        }
        .mapError { ServiceError.error($0) }
        .eraseToAnyPublisher()
    }
}

class StubImageUploadService: ImageUploadServiceProtocol {
    func upload(_ image: UIImage, compressionQuality: CGFloat, path: String) -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
