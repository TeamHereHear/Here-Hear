//
//  RemoteImageViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/11/24.
//

import UIKit
import Combine

final class RemoteImageViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var imageLoadingState: RemoteImageLoadingState = .none
    
    private let container: DIContainer
    private let path: String
    public let isStorageImage: Bool
    
    init(
        container: DIContainer,
        path: String,
        isStorageImage: Bool
    ) {
        self.container = container
        self.path = path
        self.isStorageImage = isStorageImage
    }
    
    @MainActor
    func fetch() async {
        self.imageLoadingState = .loading
        
        guard !isStorageImage else {
            self.imageLoadingState = .failed
             return
        }
        
        do {
            self.image = try await container.services.imageService.image(forUrlPath: path)
            
            self.imageLoadingState = .finished
        } catch {
            self.imageLoadingState = .failed
        }
    }
    
    @MainActor
    func fetchFromStoragePath() async {
        self.imageLoadingState = .loading
        
        guard isStorageImage else {
            self.imageLoadingState = .failed
             return
        }
        
        guard let url = try? await container.services.storageImageService.url(fromStoragePath: path) else {
            self.imageLoadingState = .failed
            return
        }
        
        do {
            self.image = try await container.services.imageService.image(forUrlPath: url.absoluteString)
            self.imageLoadingState = .finished
        } catch {
            self.imageLoadingState = .failed
        }
        
    }
    
}
