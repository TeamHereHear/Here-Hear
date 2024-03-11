//
//  StorageImageService.swift
//  Here-Hear
//
//  Created by Martin on 3/11/24.
//

import Foundation
import FirebaseStorage

protocol StorageImageServiceProtocol {
    func url(fromStoragePath storagePath: String) async throws -> URL?
}

final class StorageImageService: StorageImageServiceProtocol {
    private let storageRef = Storage.storage().reference()
    func url(fromStoragePath storagePath: String) async throws -> URL? {
        try await storageRef.child(storagePath).downloadURL()
    }
}

final class StubStorageImageService: StorageImageServiceProtocol {
    func url(fromStoragePath storagePath: String) async throws -> URL? {
        nil
    }

}
