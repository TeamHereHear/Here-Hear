//
//  AuthViewModel.swift
//  Here-Hear
//
//  Created by 이원형 on 2/23/24.
//

import Foundation
import Combine
import AuthenticationServices

enum AuthState {
    case unauthenticated
    case authenticated
}

class AuthViewModel: ObservableObject {
    
    enum Action {
        case checkAuthenticationState
        case googleLogin
        case appleLogin(ASAuthorizationAppleIDRequest)
        case appleLoginCompletion(Result<ASAuthorization, Error>)
        case logout
        case signInAnonymously
    }
    
    @Published var authState: AuthState = .unauthenticated
    @Published var isLoading = false
    
    var userId: String?
    
    private var currentNonce: String?
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
        case .checkAuthenticationState:
            checkAuthenticationState()
        case .googleLogin:
            googleLogin()
        case .appleLogin(let request):
            appleLogin(request: request)
        case .appleLoginCompletion(let result):
            appleLoginCompletion(result: result)
        case .logout:
            logout()
        case .signInAnonymously:
            signInAnonymously()
        }
    }
    
    private func checkAuthenticationState() {
                if let userId = container.services.authService.checkAuthenticationState() {
                    self.userId = userId
                    self.authState = .authenticated
                }
    }
    
    private func googleLogin() {
        isLoading = true
        container.services.authService.signInWithGoogle()
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] user in // user정보 받게되면 viewModel에서 갖고 있기
                self?.isLoading = false
                self?.userId = user.id
                self?.authState = .authenticated
            }.store(in: &subscriptions)
    }
    
    private func appleLogin(request: ASAuthorizationAppleIDRequest) {
        let nonce = container.services.authService.handleSignInWithAppleRequest(request)
        currentNonce = nonce
    }
    
    private func appleLoginCompletion(result: Result<ASAuthorization, Error>) {
        if case let .success(authorization) = result {
            guard let nonce = currentNonce else { return }
            
            container.services.authService.handleSignInWithAppleCompletion(authorization, none: nonce)
                .sink { [weak self] completion in
//                    if case .failure = completion {
//                        self?.isLoading = false
//                    }
                    switch completion {
                    case .failure:
                        self?.isLoading = false
                    case .finished:
                        self?.isLoading = false
                        self?.authState = .authenticated
                    }
                
                }receiveValue: { [weak self] user in
                    self?.isLoading = false
                    self?.userId = user.id
                    self?.authState = .authenticated
                }.store(in: &subscriptions)
        } else if case let .failure(error) = result {
            isLoading = false
            print(error.localizedDescription)
        }
    }
    
    private func logout() {
        container.services.authService.logout()
            .sink { _ in
            }receiveValue: { [weak self] _ in
                self?.authState = .unauthenticated
                self?.userId = nil
            }.store(in: &subscriptions)
    }
    
    private func signInAnonymously() {
        isLoading = true
        container.services.authService.signInAnonyMously()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure = completion {
                    
                }
            } receiveValue: { [weak self] user in
                self?.userId = user.id
                self?.authState = .authenticated
            }.store(in: &subscriptions)
    }
}
