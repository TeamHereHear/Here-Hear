//
//  RegisterProfileImageViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/5/24.
//

import SwiftUI
import Combine

final class RegisterProfileImageViewModel: ObservableObject {
    @Published var showProfileImagePicker: Bool = false
    @Published var image: UIImage?
    @Published var didComplete: Bool = false
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    enum Action {
        case showImagePicker
        case skip
        case upload
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(_ action: Action) {
        switch action {
        case .showImagePicker:
            Task {
                await showImagePicker()
            }
        case .skip:
            Task {
                await complete()
            }
        case .upload:
            upload()
        }
    }
    
    private func upload() {
        guard let image else { return }
        guard let userId = container.services.authService.checkAuthenticationState() else { return }
        
        let path: String = "UserProfile/\(userId)/profile.jpg"
        
        container.services.imageUploadService.upload(image, compressionQuality: 0.5, path: path)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    Task {
                        await self.complete()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func complete() {
        self.didComplete = true
    }
    
    @MainActor
    private func showImagePicker() {
        showProfileImagePicker = true
    }
}
