//
//  RegisterNicknameViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/4/24.
//

import Foundation
import Combine

class RegisterNicknameViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var isValidNickname: Bool = false
    @Published var didSetNickname: Bool = false

    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func registerNickname() {
        guard isValidNickname else { return }
        guard let id = container.services.authService.checkAuthenticationState() else { return }
        
        let newUser: UserModel = .init(id: id, nickname: nickname, createdAt: Date.now)
        
        container.services.userService.addUser(newUser)
            .sink { [weak self] completion in
                guard let self else { return }
                
                if case .finished = completion {
                    self.didSetNickname = true
                }

            } receiveValue: { _ in
            }
            .store(in: &cancellables)

    }
}
