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
    case uploadError(Error? = nil)
    case downloadUrlError(Error? = nil)
    case nilSelf
    case error(Error)
}

protocol ImageUploadServiceProtocol {
    func upload(
        _ image: UIImage,
        compressionQuality: CGFloat,
        path: String
    ) -> AnyPublisher<URL?, ServiceError>
    
    func upload(
        _ image: UIImage,
        compressionQuality: CGFloat,
        path: String
    ) async throws -> URL?
}

class ImageUploadService: ImageUploadServiceProtocol {
    private let storageRef = Storage.storage().reference()
    
    func upload(_ image: UIImage, compressionQuality: CGFloat = 0.5, path: String) -> AnyPublisher<URL?, ServiceError> {
        Future<URL?, ImageUploadServiceError> { [weak self] promise in
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
                    promise(.failure(.uploadError(error)))
                    return
                }
                
                self.storageRef.child(path).downloadURL { url, error in
                    if let error {
                        promise(.failure(.downloadUrlError(error)))
                        return
                    }
                    
                    promise(.success(url))
                }
            }
        }
        .mapError { ServiceError.error($0) }
        .eraseToAnyPublisher()
    }
    
    func upload(
        _ image: UIImage,
        compressionQuality: CGFloat = 0.5,
        path: String
    ) async throws -> URL? {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageUploadServiceError.encodingError
        }
        
        do {
            _ = try await storageRef.child(path).putDataAsync(data)
        } catch {
            throw ImageUploadServiceError.uploadError()
        }
        
        do {
            let url = try await storageRef.child(path).downloadURL()
            return url
        } catch {
            throw ImageUploadServiceError.downloadUrlError()
        }
    }
}

class StubImageUploadService: ImageUploadServiceProtocol {
    func upload(_ image: UIImage, compressionQuality: CGFloat, path: String) -> AnyPublisher<URL?, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func upload(_ image: UIImage, compressionQuality: CGFloat, path: String) async throws -> URL? {
        nil
    }
}
