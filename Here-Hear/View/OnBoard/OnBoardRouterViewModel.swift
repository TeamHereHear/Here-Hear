//
//  OnBoardRouterViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/4/24.
//

import Foundation
import Combine

final class OnBoardRouterViewModel: ObservableObject {
    @Published var onBoardRoute: OnBoardRoute = .none
    @Published var loadingState: LoadingState = .none
    
    enum OnBoardRoute: Int, Hashable {
        case none = 0
        case existingUser
        case newUser
        case anonymousUser
        case failed
    }
    
    enum LoadingState: Int, Hashable {
        case none = 1
        case loading
        case finished
        case failed
    }
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func setOnBoardRoute() {
        guard let id = container.services.authService.checkAuthenticationState() else {
            return
        }
        
        /// 익명의 사용자라면 User컬렉션에 등록
        if container.services.authService.isAnonyMousUser() {
            addAnonymousUser(ofId: id)
            return
        }
        
        /// 익명사용자가 아니라면 유저 정보 등록 여부 기준으로
        container.services.userService.fetchUser(ofId: id)
            .sink { [weak self] completion in
                guard let self else { return }
                
                if case .failure = completion {
                    self.onBoardRoute = .failed
                }
                
            } receiveValue: { [weak self] userModel in
                guard let self else { return }
                
                self.onBoardRoute = userModel != nil ? .existingUser : .newUser
            }
            .store(in: &cancellables)
    }
    
    private func addAnonymousUser(ofId id: String) {
        container.services.userService.addUser(.init(id: id, nickname: "", createdAt: .now))
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished: 
                    self.onBoardRoute = .anonymousUser
                case .failure: 
                    self.onBoardRoute = .failed
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
    }
}
